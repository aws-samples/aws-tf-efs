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
| <a name="provider_aws.primary"></a> [aws.primary](#provider\_aws.primary) | 4.19.0 |
| <a name="provider_aws.replica"></a> [aws.replica](#provider\_aws.replica) | 4.19.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.2.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_efs_kms"></a> [efs\_kms](#module\_efs\_kms) | github.com/aws-samples/aws-tf-kms//modules/aws/kms | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_efs_access_point.efs_ap](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_file_system_policy.efs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system_policy) | resource |
| [aws_efs_mount_target.efs_mount](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_efs_replication_configuration.efs_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_replication_configuration) | resource |
| [aws_security_group.efs_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress_efs_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_efs_name"></a> [efs\_name](#input\_efs\_name) | A unique name to reference the EFS replica. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name (prefix/suffix) to be used for all the resource identifications | `string` | n/a | yes |
| <a name="input_replica_region"></a> [replica\_region](#input\_replica\_region) | The AWS Region e.g. us-west-1 where replica will be created | `string` | n/a | yes |
| <a name="input_source_efs_id"></a> [source\_efs\_id](#input\_source\_efs\_id) | EFS File System ID for the source EFS in the `primary_region`,<br>for which replication will be created in the `replica_region` | `string` | n/a | yes |
| <a name="input_subnet_tags"></a> [subnet\_tags](#input\_subnet\_tags) | Tags to discover target subnets in the VPC in the `replica_region`, these tags should identify one or more subnets | `map(string)` | n/a | yes |
| <a name="input_vpc_tags"></a> [vpc\_tags](#input\_vpc\_tags) | Tags to discover target VPC in the `replica_region`, these tags should uniquely identify a VPC | `map(string)` | n/a | yes |
| <a name="input_availability_zone_name"></a> [availability\_zone\_name](#input\_availability\_zone\_name) | The AWS Availability Zone where read-only EFS replication will be provisioned.<br>For example: "us-west-1b"<br>If null, EFS replication with use regional storage class | `string` | `null` | no |
| <a name="input_efs_access_point_specs"></a> [efs\_access\_point\_specs](#input\_efs\_access\_point\_specs) | List of EFS Access Point Specs that will be created in the replica EFS.<br>- `efs_ap`, required. Unique name to identify access point<br>- `uid`, required. e.g. 0<br>- `gid`, required. e.g. 0<br>- `secondary_gids`, required. e.g. []<br>- `root_path`, required. e.g. /{env}/{project}/{purpose}/{name}<br>- `owner_uid`, required. e.g. 0<br>- `owner_gid`, required. e.g. 0<br>- `root_permission`, required e.g. 0755<br>- `principal_arns`, required. User or Role ARNs that need access to this access point e.g. ["*"] | <pre>list(object({<br>    efs_ap          = string<br>    uid             = number<br>    gid             = number<br>    secondary_gids  = list(number)<br>    root_path       = string<br>    owner_uid       = number<br>    owner_gid       = number<br>    root_permission = string<br>    principal_arns  = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | Environment name e.g. dev, prod | `string` | `"dev"` | no |
| <a name="input_kms_admin_roles"></a> [kms\_admin\_roles](#input\_kms\_admin\_roles) | List Administrator roles for KMS.<br>Provide at least one Admin role if `kms_alias` is empty | `list(string)` | `[]` | no |
| <a name="input_kms_alias"></a> [kms\_alias](#input\_kms\_alias) | The alias for an existing AWS KMS key in the replica region.<br>if null, a new AWS KMS Key is created in the replica region | `string` | `null` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | Tags to discover an existing security group for the EFS replica.<br>These tags should uniquely identify a security group<br>if null, new Security Group will be created | `map(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Common and mandatory tags for the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_efs"></a> [efs](#output\_efs) | Elastic File System info for the replicated EFS |
| <a name="output_efs_ap"></a> [efs\_ap](#output\_efs\_ap) | Elastic File System Access Point info |
| <a name="output_efs_kms_aliases"></a> [efs\_kms\_aliases](#output\_efs\_kms\_aliases) | Outputs from KMS module key\_aliases |
| <a name="output_efs_kms_policies"></a> [efs\_kms\_policies](#output\_efs\_kms\_policies) | Outputs from KMS module key\_policies |
<!-- END_TF_DOCS -->
