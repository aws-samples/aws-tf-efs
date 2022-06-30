module "efs_kms" {
  source = "github.com/aws-samples/aws-tf-kms//modules/aws/kms?ref=v1.0.0"
  providers = {
    aws = aws.replica
  }

  count = local.create_kms ? 1 : 0

  region = var.replica_region

  project  = var.project
  env_name = var.env_name

  tags = var.tags

  kms_alias_prefix = var.project
  kms_admin_roles  = var.kms_admin_roles
  kms_usage_roles  = []

  enable_kms_efs          = true
  enable_multi_region_efs = true
}
