<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= v1.1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.13.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | 2.2.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.19.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.2.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_efs_kms"></a> [efs\_kms](#module\_efs\_kms) | github.com/aws-samples/aws-tf-kms//modules/aws/kms | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_efs_access_point.efs_ap](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_backup_policy.backup_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_backup_policy) | resource |
| [aws_efs_file_system.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_file_system_policy.efs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system_policy) | resource |
| [aws_efs_mount_target.efs_mount](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_security_group.efs_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress_efs_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_efs_name"></a> [efs\_name](#input\_efs\_name) | A unique name to reference the EFS. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name (prefix/suffix) to be used on all the resources identification | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS Region e.g. us-east-1 for the environment | `string` | n/a | yes |
| <a name="input_availability_zone_name"></a> [availability\_zone\_name](#input\_availability\_zone\_name) | The AWS Availability Zone in which to create the file system.<br>If not empty, EFS will be created with One Zone storage class.<br>For example: "us-east-1a"<br>The `subnet_tags` must identify the target subnets in this AZ.<br>Not applicable if `efs_id` is provided | `string` | `null` | no |
| <a name="input_backup_plan"></a> [backup\_plan](#input\_backup\_plan) | Backup plan for the EFS<br>Valid values: `AUTO` or `CUSTOM`<br>Not applicable if `efs_id` is provided | `string` | `"CUSTOM"` | no |
| <a name="input_efs_access_point_specs"></a> [efs\_access\_point\_specs](#input\_efs\_access\_point\_specs) | List of EFS Access Point Specs that will be created.<br>- `efs_ap`, required. Unique name to identify access point<br>- `uid`, required. e.g. 0<br>- `gid`, required. e.g. 0<br>- `secondary_gids`, required. e.g. []<br>- `root_path`, required. e.g. /{env}/{project}/{purpose}/{name}<br>- `owner_uid`, required. e.g. 0<br>- `owner_gid`, required. e.g. 0<br>- `root_permission`, required e.g. 0755<br>- `principal_arns`, required. User or Role ARNs that need access to this access point e.g. ["*"] | <pre>list(object({<br>    efs_ap          = string<br>    uid             = number<br>    gid             = number<br>    secondary_gids  = list(number)<br>    root_path       = string<br>    owner_uid       = number<br>    owner_gid       = number<br>    root_permission = string<br>    principal_arns  = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_efs_id"></a> [efs\_id](#input\_efs\_id) | File System ID. (required, if module is used to create new EFS access point(s) for an existing EFS)<br>if null, new EFS will be created | `string` | `null` | no |
| <a name="input_efs_tags"></a> [efs\_tags](#input\_efs\_tags) | Tags for the EFS.<br>For example<pre>tags = {<br>  "BackupPlan" = "EVERY-DAY"<br>}</pre> | `map(string)` | `{}` | no |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | Should EFS be encrypted?<br>Not applicable if `efs_id` is provided | `bool` | `true` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | Environment name e.g. dev, prod | `string` | `"dev"` | no |
| <a name="input_kms_admin_roles"></a> [kms\_admin\_roles](#input\_kms\_admin\_roles) | List Administrator roles for KMS.<br>Provide at least one Admin role if `kms_alias` is empty | `list(string)` | `[]` | no |
| <a name="input_kms_alias"></a> [kms\_alias](#input\_kms\_alias) | Use the given alias or create a new KMS like alias/{var.project}/efs | `string` | `null` | no |
| <a name="input_performance_mode"></a> [performance\_mode](#input\_performance\_mode) | The file system performance mode.<br>Value values: `generalPurpose` or `maxIO`.<br>Not applicable if `efs_id` is provided | `string` | `"generalPurpose"` | no |
| <a name="input_provisioned_throughput_in_mibps"></a> [provisioned\_throughput\_in\_mibps](#input\_provisioned\_throughput\_in\_mibps) | The throughput, measured in MiB/s.<br>Only applicable with `throughput_mode` set to `provisioned`.<br>Not applicable if `efs_id` is provided | `number` | `1` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | Tags to discover an existing security group for the new EFS.<br>These tags should uniquely identify a security group<br>if null, new Security Group will be created<br>Not applicable if `efs_id` is provided | `map(string)` | `null` | no |
| <a name="input_subnet_tags"></a> [subnet\_tags](#input\_subnet\_tags) | Tags to discover target subnets in the VPC, these tags should identify one or more subnets<br>Required, if `efs_id` is null, i.e. new EFS is being created and mount target(s) are being created | `map(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Common and mandatory tags for the resources | `map(string)` | `{}` | no |
| <a name="input_throughput_mode"></a> [throughput\_mode](#input\_throughput\_mode) | Throughput mode for the file system.<br>Valid values: `bursting`, or `provisioned`.<br>When using provisioned, also set `provisioned_throughput_in_mibps` (1-1024).<br>Not applicable if `efs_id` is provided | `string` | `"bursting"` | no |
| <a name="input_transition_to_ia"></a> [transition\_to\_ia](#input\_transition\_to\_ia) | When to transition files to the IA storage class.<br>Valid values: `NONE`, `AFTER_7_DAYS`, `AFTER_14_DAYS`, `AFTER_30_DAYS`, `AFTER_60_DAYS`, or `AFTER_90_DAYS`.<br>Not applicable if `efs_id` is provided | `string` | `"AFTER_7_DAYS"` | no |
| <a name="input_vpc_tags"></a> [vpc\_tags](#input\_vpc\_tags) | Tags to discover target VPC, these tags should uniquely identify a VPC<br>Required, if `efs_id` is null, i.e. new EFS is being created and mount target(s) are being created | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_efs"></a> [efs](#output\_efs) | Elastic File System info |
| <a name="output_efs_ap"></a> [efs\_ap](#output\_efs\_ap) | Elastic File System Access Point info |
| <a name="output_efs_kms_aliases"></a> [efs\_kms\_aliases](#output\_efs\_kms\_aliases) | Outputs from KMS module key\_aliases |
| <a name="output_efs_kms_policies"></a> [efs\_kms\_policies](#output\_efs\_kms\_policies) | Outputs from KMS module key\_policies |
<!-- END_TF_DOCS -->
