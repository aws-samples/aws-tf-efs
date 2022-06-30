# data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  count = local.create_efs && var.vpc_tags != null ? 1 : 0
  tags  = var.vpc_tags
}

data "aws_subnets" "subnets" {
  count = local.create_efs && var.vpc_tags != null && var.subnet_tags != null ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc[0].id]
  }
  tags = var.subnet_tags
}

data "aws_kms_key" "efs_cmk" {
  count  = local.create_kms ? 1 : 0
  key_id = local.kms_alias

  depends_on = [
    module.efs_kms
  ]
}
