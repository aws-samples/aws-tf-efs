/*---------------------------------------------------------
Provider Variable
---------------------------------------------------------*/
variable "region" {
  description = "The AWS Region e.g. us-east-1 for the environment"
  type        = string
}

/*---------------------------------------------------------
Common Variables
---------------------------------------------------------*/
variable "project" {
  description = "Project name (prefix/suffix) to be used on all the resources identification"
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
  description = <<-EOF
  Tags to discover target VPC, these tags should uniquely identify a VPC
  Required, if `efs_id` is null, i.e. new EFS is being created and mount target(s) are being created
  EOF
  type        = map(string)
  default     = null
}

variable "subnet_tags" {
  description = <<-EOF
  Tags to discover target subnets in the VPC, these tags should identify one or more subnets
  Required, if `efs_id` is null, i.e. new EFS is being created and mount target(s) are being created
  EOF
  type        = map(string)
  default     = null
}

/*---------------------------------------------------------
Elastic File System Variables
---------------------------------------------------------*/
variable "kms_alias" {
  description = "Use the given alias or create a new KMS like alias/{var.project}/efs"
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

variable "efs_name" {
  description = "A unique name to reference the EFS."
  type        = string
}

variable "efs_id" {
  description = <<-EOF
  File System ID. (required, if module is used to create new EFS access point(s) for an existing EFS)
  if null, new EFS will be created
  EOF
  type        = string
  default     = null
}

variable "encrypted" {
  description = <<-EOF
  Should EFS be encrypted?
  Not applicable if `efs_id` is provided
  EOF
  type        = bool
  default     = true
}

variable "availability_zone_name" {
  description = <<-EOF
  The AWS Availability Zone in which to create the file system.
  If not empty, EFS will be created with One Zone storage class.
  For example: "us-east-1a"
  The `subnet_tags` must identify the target subnets in this AZ.
  Not applicable if `efs_id` is provided
  EOF
  type        = string
  default     = null
}

variable "performance_mode" {
  description = <<-EOF
  The file system performance mode.
  Value values: `generalPurpose` or `maxIO`.
  Not applicable if `efs_id` is provided
  EOF
  type        = string
  default     = "generalPurpose"
  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.performance_mode)
    error_message = "Error: performance_mode Valid values: generalPurpose or maxIO."
  }
}

variable "throughput_mode" {
  description = <<-EOF
  Throughput mode for the file system.
  Valid values: `bursting`, or `provisioned`.
  When using provisioned, also set `provisioned_throughput_in_mibps` (1-1024).
  Not applicable if `efs_id` is provided
  EOF
  type        = string
  default     = "bursting"
  validation {
    condition     = contains(["bursting", "provisioned"], var.throughput_mode)
    error_message = "Error: throughput_mode Valid values: bursting, or provisioned. When using provisioned, also set provisioned_throughput_in_mibps (1-1024)."
  }
}

variable "provisioned_throughput_in_mibps" {
  description = <<-EOF
  The throughput, measured in MiB/s.
  Only applicable with `throughput_mode` set to `provisioned`.
  Not applicable if `efs_id` is provided
  EOF
  type        = number
  default     = 1
  validation {
    condition     = var.provisioned_throughput_in_mibps > 0 && var.provisioned_throughput_in_mibps < 1024
    error_message = "Error: throughput_mode Valid values: bursting, or provisioned. When using provisioned, also set provisioned_throughput_in_mibps (1-1024)."
  }
}

variable "transition_to_ia" {
  description = <<-EOF
  When to transition files to the IA storage class.
  Valid values: `NONE`, `AFTER_7_DAYS`, `AFTER_14_DAYS`, `AFTER_30_DAYS`, `AFTER_60_DAYS`, or `AFTER_90_DAYS`.
  Not applicable if `efs_id` is provided
  EOF
  type        = string
  default     = "AFTER_7_DAYS"
  validation {
    condition     = contains(["NONE", "AFTER_7_DAYS", "AFTER_14_DAYS", "AFTER_30_DAYS", "AFTER_60_DAYS", "AFTER_90_DAYS"], var.transition_to_ia)
    error_message = "Error: transition_to_ia Valid values: NONE, AFTER_7_DAYS, AFTER_14_DAYS, AFTER_30_DAYS, AFTER_60_DAYS, or AFTER_90_DAYS."
  }
}

variable "security_group_tags" {
  description = <<-EOF
  Tags to discover an existing security group for the new EFS.
  These tags should uniquely identify a security group
  if null, new Security Group will be created
  Not applicable if `efs_id` is provided
  EOF
  type        = map(string)
  default     = null
}

variable "backup_plan" {
  description = <<-EOF
  Backup plan for the EFS
  Valid values: `AUTO` or `CUSTOM`
  Not applicable if `efs_id` is provided
  EOF
  type        = string
  default     = "CUSTOM"
  validation {
    condition     = contains(["AUTO", "CUSTOM"], var.backup_plan)
    error_message = "Error: backup_plan Valid values: AUTO, or CUSTOM."
  }
}

variable "efs_access_point_specs" {
  description = <<-EOF
  List of EFS Access Point Specs that will be created.
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

variable "efs_tags" {
  description = <<-EOF
  Tags for the EFS.
  For example
  ```
  tags = {
    "BackupPlan" = "EVERY-DAY"
  }
  ```
  EOF
  type        = map(string)
  default     = {}
}
