/*---------------------------------------------------------
Provider Variable
---------------------------------------------------------*/
region = "us-east-1"

/*---------------------------------------------------------
Common Variables
---------------------------------------------------------*/
project  = "aws-tf-efs-vpc"
env_name = "dev"
tags = {
  Env     = "DEV"
  Project = "aws-tf-efs-vpc"
}

/*---------------------------------------------------------
VPC Variables
---------------------------------------------------------*/
vpc_tags = {
  "efs/scenario" = "1"
  "Env"          = "DEV"
}

vpc_public_subnet_tags = {}

vpc_private_subnet_tags = {
  "efs/scenario" = "1"
  "Env"          = "DEV"
}

r53_zone_names = []
