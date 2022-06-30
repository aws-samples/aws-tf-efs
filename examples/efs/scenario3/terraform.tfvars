/*---------------------------------------------------------
Provider Variable
---------------------------------------------------------*/
region = "us-east-1"

/*---------------------------------------------------------
Common Variables
---------------------------------------------------------*/
project  = "scenario3-efs"
env_name = "dev"
tags = {
  Env     = "DEV"
  Project = "scenario3-efs"
}

/*---------------------------------------------------------
EFS Variables
---------------------------------------------------------*/
efs_id = "<efs-id-from-scenario2>"

efs_access_point_specs = [
  {
    efs_ap          = "efs-scenario3-ap1"
    uid             = 0
    gid             = 0
    secondary_gids  = []
    root_path       = "/dev/efs/scenario3/efs_scenario3_ap1"
    owner_uid       = 0
    owner_gid       = 0
    root_permission = "0755"
    principal_arns  = ["*"]
  },
  {
    efs_ap          = "efs-scenario3-ap2"
    uid             = 0
    gid             = 0
    secondary_gids  = []
    root_path       = "/dev/efs/scenario3/efs_scenario3_ap2"
    owner_uid       = 0
    owner_gid       = 0
    root_permission = "0755"
    principal_arns  = ["*"] //["<list-of-role-arns>"]
  }
]
