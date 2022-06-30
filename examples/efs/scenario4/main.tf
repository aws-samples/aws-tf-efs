module "owned_efs" {
  source = "../../../modules/aws/efs"

  region = var.region

  project  = var.project
  env_name = var.env_name

  tags = var.tags

  vpc_tags    = var.vpc_tags
  subnet_tags = var.subnet_tags

  kms_alias       = var.kms_alias
  kms_admin_roles = ["Admin"]

  efs_name            = "scenario4"
  efs_id              = var.efs_id
  security_group_tags = var.security_group_tags

  efs_access_point_specs = var.efs_access_point_specs
}

# Example create KMS replica
# module "kms_key_replica_usw1" {
#   source = "github.com/aws-samples/aws-tf-kms//modules/aws/kms_replica"
#   providers = {
#     aws.primary = aws
#     aws.replica = aws.usw1
#   }

#   primary_region = var.region
#   replica_region = "us-west-1"

#   project  = var.project
#   env_name = var.env_name

#   tags = var.tags

#   replicas_to_create = {
#     "efs" = {
#       "alias"  = module.owned_efs.efs.kms_alias
#       "policy" = module.owned_efs.efs.key_policy
#     }
#   }

#   depends_on = [
#     module.owned_efs
#   ]
# }

module "owned_efs_replica_usw1" {
  source = "../../../modules/aws/efs_replica"
  providers = {
    aws.primary = aws
    aws.replica = aws.usw1
  }

  replica_region = "us-west-1"

  # Example: Single Zone replication
  #availability_zone_name = "us-west-1b"

  project  = var.project
  env_name = var.env_name

  tags = var.tags

  source_efs_id = module.owned_efs.efs.id

  #Example: Use KMS replica
  #kms_alias = module.kms_key_replica_usw1.key_aliases["efs"]

  #Example: create KMS in target region
  kms_admin_roles = ["Admin"]

  #VPC in replica_region
  vpc_tags = var.vpc_tags

  # Example: regional replication, mount to multiple subnets
  subnet_tags = var.subnet_tags

  # Example: Single Zone replication, mount to single subnet
  # subnet_tags = {
  #   "efs/scenario"    = "1"
  #   "Env"             = "DEV"
  #   "efs/single-zone" = "1"
  # }

  efs_name               = "scenario4-replica"
  efs_access_point_specs = var.efs_access_point_specs
}
