resource "aws_efs_replication_configuration" "efs_replication" {
  provider = aws.primary

  source_file_system_id = data.aws_efs_file_system.primary_efs.file_system_id
  destination {
    availability_zone_name = var.availability_zone_name
    region                 = try(length(var.availability_zone_name), 0) == 0 ? var.replica_region : null
    kms_key_id             = var.kms_alias
  }
}

data "aws_efs_file_system" "efs" {
  provider = aws.replica

  file_system_id = aws_efs_replication_configuration.efs_replication.destination[0].file_system_id
}

locals {
  efs = {
    name       = var.efs_name
    id         = data.aws_efs_file_system.efs.file_system_id
    arn        = data.aws_efs_file_system.efs.arn
    dns_name   = data.aws_efs_file_system.efs.dns_name
    sg_id      = var.security_group_tags != null ? data.aws_security_group.efs_sg[0].id : aws_security_group.efs_sg[0].id
    sg_tags    = var.security_group_tags != null ? var.security_group_tags : aws_security_group.efs_sg[0].tags
    kms_alias  = local.kms_alias
    key_policy = local.create_kms ? module.efs_kms[0].key_policies["efs"] : null
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  provider = aws.replica

  for_each        = toset(data.aws_subnets.subnets.ids)
  file_system_id  = local.efs.id
  subnet_id       = each.value
  security_groups = [local.efs.sg_id]
}

resource "aws_efs_access_point" "efs_ap" {
  for_each = { for efs_ap in var.efs_access_point_specs : "${var.efs_name}-${efs_ap.efs_ap}" => efs_ap }

  provider = aws.replica

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
    file_system_id = local.efs.id
    aws_region     = var.replica_region
  }
}

#efs resource policy
data "aws_iam_policy_document" "efs_policy" {
  provider = aws.replica

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
  provider = aws.replica

  file_system_id = local.efs.id

  bypass_policy_lockout_safety_check = false

  policy = data.aws_iam_policy_document.efs_policy.json
}
