module "shared_efs" {
  source = "../../../modules/aws/efs"

  region = var.region

  project  = var.project
  env_name = var.env_name

  tags = var.tags

  efs_name = "scenario3"
  #Use an existing File System ID, e.g. from Scenario2
  efs_id = var.efs_id

  efs_access_point_specs = var.efs_access_point_specs
}
