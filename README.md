# Terraform idp-scim-sync

This module is based off of [slashdevops/idp-scim-sync](https://github.com/slashdevops/idp-scim-sync) and allows you to deploy the idp-scim-sync lambda function using terraform.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_semantic_version"></a> [semantic\_version](#input\_semantic\_version) | The semantic version of the module | `string` | n/a | yes |
| <a name="input_architecture"></a> [architecture](#input\_architecture) | The Lambda function architecture | `string` | `"arm64"` | no |
| <a name="input_bucket_name_prefix"></a> [bucket\_name\_prefix](#input\_bucket\_name\_prefix) | Prefix used in the bucket name where the state data will be stored. | `string` | `"idp-scim-sync-state"` | no |
| <a name="input_gws_groups_filter"></a> [gws\_groups\_filter](#input\_gws\_groups\_filter) | The Google Workspace group filter query parameter | `string` | `""` | no |
| <a name="input_gws_service_account_file_secret_name"></a> [gws\_service\_account\_file\_secret\_name](#input\_gws\_service\_account\_file\_secret\_name) | The Google Workspace credentials file secret name | `string` | `"IDPSCIM_GWSServiceAccountFile"` | no |
| <a name="input_gws_user_email_secret_name"></a> [gws\_user\_email\_secret\_name](#input\_gws\_user\_email\_secret\_name) | The Google Workspace user email secret name | `string` | `"IDPSCIM_GWSUserEmail"` | no |
| <a name="input_lambda_function_handler"></a> [lambda\_function\_handler](#input\_lambda\_function\_handler) | The Lambda function handler | `string` | `"bootstrap"` | no |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | Name of the created Lambda function | `string` | `"idp-scim-sync"` | no |
| <a name="input_log_format"></a> [log\_format](#input\_log\_format) | Log format for Lambda function logging | `string` | `"json"` | no |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | The name of the CloudWatch log group | `string` | `"/aws/lambda/idp-scim-sync"` | no |
| <a name="input_log_group_retention_days"></a> [log\_group\_retention\_days](#input\_log\_group\_retention\_days) | The number of days you want to keep logs for the lambda function | `number` | `7` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Log level for Lambda function logging | `string` | `"info"` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | The amount of memory to allocate to the Lambda function. | `number` | `256` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | The Lambda function runtime | `string` | `"provided.al2"` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | Schedule for trigger the execution of idp-scim-sync (see EventBridge rule schedule expressions) | `string` | `"rate(15 minutes)"` | no |
| <a name="input_scim_access_token_secret_name"></a> [scim\_access\_token\_secret\_name](#input\_scim\_access\_token\_secret\_name) | The AWS SSO SCIM AccessToken secret name | `string` | `"IDPSCIM_SCIMAccessToken"` | no |
| <a name="input_scim_endpoint_secret_name"></a> [scim\_endpoint\_secret\_name](#input\_scim\_endpoint\_secret\_name) | The AWS SSO SCIM Endpoint Url secret name | `string` | `"IDPSCIM_SCIMEndpoint"` | no |
| <a name="input_state_file_key"></a> [state\_file\_key](#input\_state\_file\_key) | The key 'file' where the state data will be stored | `string` | `"data/state.json"` | no |
| <a name="input_sync_method"></a> [sync\_method](#input\_sync\_method) | The sync method to use | `string` | `"groups"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | The amount of time that AWS Lambda service allows a function to run before terminating it. | `number` | `300` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The ARN of the S3 bucket |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | The name of the S3 bucket |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The ARN of the KMS key |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | The ID of the KMS key |
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | The ARN of the Lambda function |
<!-- END_TF_DOCS -->
