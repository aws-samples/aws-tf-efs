/*---------------------------------------------------------
Provider Variable
---------------------------------------------------------*/
region = "us-east-1"

/*---------------------------------------------------------
Common Variables
---------------------------------------------------------*/
project  = "scenario2-efs"
env_name = "dev"
tags = {
  Env     = "DEV"
  Project = "scenario2-efs"
}

/*---------------------------------------------------------
Data Source Variables
---------------------------------------------------------*/
#Make sure that target VPC is identified uniquely via these tags
vpc_tags = {
  "efs/scenario" = "1"
  "Env"          = "DEV"
}

#Make sure that target subnets are tagged correctly
subnet_tags = {
  "efs/scenario" = "1"
  "Env"          = "DEV"
  #"efs/single-zone" = "1"
}

/*---------------------------------------------------------
EFS Variables
---------------------------------------------------------*/
efs_id              = null
kms_alias           = null
security_group_tags = null

efs_access_point_specs = [
  #   {
  #     efs_ap          = "efs-scenario2-ap1"
  #     uid             = 0
  #     gid             = 0
  #     secondary_gids  = []
  #     root_path       = "/dev/efs/scenario2/efs_scenario2_ap1"
  #     owner_uid       = 0
  #     owner_gid       = 0
  #     root_permission = "0755"
  #     principal_arns  = ["*"] //["<list-of-role-arns>"]
  #   }
]
