data "aws_efs_file_system" "efs" {
  count          = local.create_efs ? 0 : 1
  file_system_id = var.efs_id
}

resource "aws_efs_file_system" "efs" {
  count            = local.create_efs ? 1 : 0
  creation_token   = "${var.project}-${var.efs_name}-efs"
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode
  encrypted        = var.encrypted
  kms_key_id       = local.create_kms ? data.aws_kms_key.efs_cmk[0].arn : null

  availability_zone_name = var.availability_zone_name

  provisioned_throughput_in_mibps = var.throughput_mode == "provisioned" ? var.provisioned_throughput_in_mibps : null

  dynamic "lifecycle_policy" {
    for_each = var.transition_to_ia == "NONE" ? [] : [var.transition_to_ia]
    content {
      transition_to_ia = var.transition_to_ia
    }
  }

  dynamic "lifecycle_policy" {
    for_each = var.transition_to_ia == "NONE" ? [] : [var.transition_to_ia]
    content {
      transition_to_primary_storage_class = "AFTER_1_ACCESS"
    }
  }

  tags = merge(
    {
      Name = "${var.project}-${var.efs_name}-efs"
    },
    var.efs_tags,
    var.tags
  )
}

resource "aws_efs_backup_policy" "backup_policy" {
  count = local.create_efs ? 1 : 0

  file_system_id = local.efs.id

  backup_policy {
    status = local.create_efs && var.backup_plan == "AUTO" ? "ENABLED" : "DISABLED"
  }
}

locals {
  efs = {
    name       = var.efs_name
    id         = var.efs_id == null ? aws_efs_file_system.efs[0].id : data.aws_efs_file_system.efs[0].id
    arn        = var.efs_id == null ? aws_efs_file_system.efs[0].arn : data.aws_efs_file_system.efs[0].arn
    dns_name   = var.efs_id == null ? aws_efs_file_system.efs[0].dns_name : data.aws_efs_file_system.efs[0].dns_name
    sg_id      = var.security_group_tags != null ? data.aws_security_group.efs_sg[0].id : var.efs_id == null ? aws_security_group.efs_sg[0].id : null
    sg_tags    = var.security_group_tags != null ? var.security_group_tags : var.efs_id == null ? aws_security_group.efs_sg[0].tags : null
    kms_alias  = local.kms_alias
    key_policy = local.create_kms ? module.efs_kms[0].key_policies["efs"] : null
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  for_each        = toset(local.create_efs ? data.aws_subnets.subnets[0].ids : [])
  file_system_id  = local.efs.id
  subnet_id       = each.value
  security_groups = [local.efs.sg_id]
}

resource "aws_efs_access_point" "efs_ap" {
  for_each       = { for efs_ap in var.efs_access_point_specs : "${var.efs_name}-${efs_ap.efs_ap}" => efs_ap }
  file_system_id = local.efs.id

  posix_user {
    uid            = each.value.uid
    gid            = each.value.gid
    secondary_gids = each.value.secondary_gids
  }

  root_directory {
    path = each.value.root_path
    creation_info {
      owner_uid   = each.value.owner_uid
      owner_gid   = each.value.owner_gid
      permissions = each.value.root_permission
    }
  }

  tags = merge(
    {
      Name = each.value.efs_ap
    },
    var.tags
  )

  depends_on = [
    #force wait for mount creation
    aws_efs_mount_target.efs_mount
  ]
}

data "external" "efs_policy" {
  program = ["python", "${path.module}/scripts/get_efs_policy.py"]
  query = {
    efs_name       = var.efs_name
    file_system_id = local.efs.id
    aws_region     = var.region
  }

  depends_on = [
    aws_efs_access_point.efs_ap
  ]
}

#efs resource policy
data "aws_iam_policy_document" "efs_policy" {
  #Use existing policy and merge statements with it
  source_policy_documents = try(length(data.external.efs_policy.result.policy), 0) != 0 ? [data.external.efs_policy.result.policy] : []

  statement {
    sid = "AllowAccessOnMountTargetViaTLSOnly"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite"
    ]
    resources = [local.efs.arn]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "true"
      ]
    }
    condition {
      test     = "Bool"
      variable = "elasticfilesystem:AccessedViaMountTarget"
      values = [
        "true"
      ]
    }
  }

  dynamic "statement" {
    for_each = [for efs_ap in var.efs_access_point_specs : {
      arn            = aws_efs_access_point.efs_ap["${var.efs_name}-${efs_ap.efs_ap}"].arn
      principal_arns = efs_ap.principal_arns
      efs_ap_id      = split("/", aws_efs_access_point.efs_ap["${var.efs_name}-${efs_ap.efs_ap}"].arn)[1]
      efs_ap         = efs_ap.efs_ap
    }]

    content {
      sid = "AllowAccessViaAP-${var.efs_name}-${statement.value.efs_ap}"
      principals {
        type        = "AWS"
        identifiers = statement.value.principal_arns
      }
      actions = [
        "elasticfilesystem:ClientRootAccess",
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite"
      ]
      resources = [local.efs.arn]
      condition {
        test     = "StringEquals"
        variable = "elasticfilesystem:AccessPointArn"
        values   = [statement.value.arn]
      }
    }
  }
}

#resource policy for EFS
resource "aws_efs_file_system_policy" "efs_policy" {
  file_system_id = local.efs.id

  bypass_policy_lockout_safety_check = false

  policy = data.aws_iam_policy_document.efs_policy.json
}
