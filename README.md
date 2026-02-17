# Terraform idp-scim-sync

This module is based off of [slashdevops/idp-scim-sync](https://github.com/slashdevops/idp-scim-sync) and allows you to deploy the idp-scim-sync lambda function using terraform.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_logs_class"></a> [cloudwatch\_logs\_class](#input\_cloudwatch\_logs\_class) | The class of CloudWatch Logs log group to create (e.g. standard or infrequent access) | `string` | `"STANDARD"` | no |
| <a name="input_cloudwatch_logs_kms_key_id"></a> [cloudwatch\_logs\_kms\_key\_id](#input\_cloudwatch\_logs\_kms\_key\_id) | The ID of the KMS key to use for encrypting CloudWatch Logs | `string` | `null` | no |
| <a name="input_cloudwatch_logs_retention_in_days"></a> [cloudwatch\_logs\_retention\_in\_days](#input\_cloudwatch\_logs\_retention\_in\_days) | The number of days to retain CloudWatch Logs | `number` | `7` | no |
| <a name="input_groups_filter"></a> [groups\_filter](#input\_groups\_filter) | The Google Workspace group filter query parameter | `string` | `"Name:Cloud*"` | no |
| <a name="input_lambda_memory_size"></a> [lambda\_memory\_size](#input\_lambda\_memory\_size) | The amount of memory to allocate to the Lambda function. | `number` | `256` | no |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | The runtime environment for the Lambda function. | `string` | `"provided.al2"` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | The amount of time (in seconds) that the Lambda function has to run before it is terminated. | `number` | `300` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Log level for Lambda function logging | `string` | `"info"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the created Lambda function | `string` | `"lz-idp-scim"` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | Schedule for trigger the execution of idp-scim-sync (see EventBridge rule schedule expressions) | `string` | `"rate(15 minutes)"` | no |
| <a name="input_semantic_version"></a> [semantic\_version](#input\_semantic\_version) | The semantic version of the module | `string` | `"0.30.1"` | no |
| <a name="input_state_file_key"></a> [state\_file\_key](#input\_state\_file\_key) | The key 'file' where the state data will be stored | `string` | `"data/state.json"` | no |
| <a name="input_sync_method"></a> [sync\_method](#input\_sync\_method) | The sync method to use | `string` | `"groups"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The ARN of the S 3 bucket |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | The name of the S3 bucket |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The ARN of the KMS key |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | The ID of the KMS key |
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | The ARN of the Lambda function |
<!-- END_TF_DOCS -->
