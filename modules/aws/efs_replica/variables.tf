/*---------------------------------------------------------
Provider Variable
---------------------------------------------------------*/
variable "replica_region" {
  description = "The AWS Region e.g. us-west-1 where replica will be created"
  type        = string
}

/*---------------------------------------------------------
Common Variables
---------------------------------------------------------*/
variable "project" {
  description = "Project name (prefix/suffix) to be used for all the resource identifications"
  type        = string
}

variable "env_name" {
  description = "Environment name e.g. dev, prod"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Common and mandatory tags for the resources"
  type        = map(string)
  default     = {}
}

/*---------------------------------------------------------
Data Source Variables
---------------------------------------------------------*/
variable "vpc_tags" {
  description = "Tags to discover target VPC in the `replica_region`, these tags should uniquely identify a VPC"
  type        = map(string)
}

variable "subnet_tags" {
  description = "Tags to discover target subnets in the VPC in the `replica_region`, these tags should identify one or more subnets"
  type        = map(string)
}

/*---------------------------------------------------------
EFS Replication Variables
---------------------------------------------------------*/
variable "source_efs_id" {
  description = <<-EOF
  EFS File System ID for the source EFS in the `primary_region`,
  for which replication will be created in the `replica_region`
  EOF
  type        = string
}

variable "kms_alias" {
  description = <<-EOF
  The alias for an existing AWS KMS key in the replica region.
  if null, a new AWS KMS Key is created in the replica region
  EOF
  type        = string
  default     = null
}

variable "kms_admin_roles" {
  description = <<-EOF
  List Administrator roles for KMS.
  Provide at least one Admin role if `kms_alias` is empty
  EOF
  type        = list(string)
  default     = []
}

variable "availability_zone_name" {
  description = <<-EOF
  The AWS Availability Zone where read-only EFS replication will be provisioned.
  For example: "us-west-1b"
  If null, EFS replication with use regional storage class
  EOF
  type        = string
  default     = null
}

variable "efs_name" {
  description = "A unique name to reference the EFS replica."
  type        = string
}

variable "security_group_tags" {
  description = <<-EOF
  Tags to discover an existing security group for the EFS replica.
  These tags should uniquely identify a security group
  if null, new Security Group will be created
  EOF
  type        = map(string)
  default     = null
}

variable "efs_access_point_specs" {
  description = <<-EOF
  List of EFS Access Point Specs that will be created in the replica EFS.
  - `efs_ap`, required. Unique name to identify access point
  - `uid`, required. e.g. 0
  - `gid`, required. e.g. 0
  - `secondary_gids`, required. e.g. []
  - `root_path`, required. e.g. /{env}/{project}/{purpose}/{name}
  - `owner_uid`, required. e.g. 0
  - `owner_gid`, required. e.g. 0
  - `root_permission`, required e.g. 0755
  - `principal_arns`, required. User or Role ARNs that need access to this access point e.g. ["*"]
  EOF
  type = list(object({
    efs_ap          = string
    uid             = number
    gid             = number
    secondary_gids  = list(number)
    root_path       = string
    owner_uid       = number
    owner_gid       = number
    root_permission = string
    principal_arns  = list(string)
  }))
  default = []
}
