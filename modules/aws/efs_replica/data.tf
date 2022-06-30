# data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  provider = aws.replica

  tags = var.vpc_tags
}

data "aws_subnets" "subnets" {
  provider = aws.replica

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  tags = var.subnet_tags
}

data "aws_efs_file_system" "primary_efs" {
  provider = aws.primary

  file_system_id = var.source_efs_id
}
