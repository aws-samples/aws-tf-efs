module "shared_efs" {
  source = "../../../modules/aws/efs"

  region = var.region

  project  = var.project
  env_name = var.env_name

  tags = var.tags

  vpc_tags    = var.vpc_tags
  subnet_tags = var.subnet_tags

  security_group_tags = var.security_group_tags

  kms_alias       = var.kms_alias
  kms_admin_roles = ["Admin"]

  efs_name = "scenario2"
  efs_id   = var.efs_id
  #throughput_mode = "provisioned"
  #performance_mode = "maxIO"
  #backup_plan = "AUTO"
  #availability_zone_name = "us-east-1a"

  efs_access_point_specs = var.efs_access_point_specs
}
