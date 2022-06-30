locals {
  create_efs = try(length(var.efs_id), 0) != 0 ? false : true
  create_kms = local.create_efs && var.encrypted && try(length(var.kms_alias), 0) == 0 ? true : false
  kms_alias  = try(length(var.kms_alias), 0) != 0 ? var.kms_alias : local.create_kms ? "alias/${var.project}/efs" : null
}
