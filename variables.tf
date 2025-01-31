variable "schedule_expression" {
  type        = string
  description = "Schedule for trigger the execution of idp-scim-sync (see EventBridge rule schedule expressions)"
  default     = "rate(15 minutes)"
}

variable "log_level" {
  type        = string
  description = "Log level for Lambda function logging"
  default     = "info"
}

variable "log_format" {
  type        = string
  description = "Log format for Lambda function logging"
  default     = "json"
}

variable "bucket_name_prefix" {
  type        = string
  description = "Prefix used in the bucket name where the state data will be stored."
  default     = "idp-scim-sync-state"
}

variable "state_file_key" {
  type        = string
  description = "The key 'file' where the state data will be stored"
  default     = "data/state.json"
}

variable "gws_service_account_file_secret_name" {
  type        = string
  description = "The Google Workspace credentials file secret name"
  default     = "IDPSCIM_GWSServiceAccountFile"
}

variable "gws_user_email_secret_name" {
  type        = string
  description = "The Google Workspace user email secret name"
  default     = "IDPSCIM_GWSUserEmail"
}

variable "scim_endpoint_secret_name" {
  type        = string
  description = "The AWS SSO SCIM Endpoint Url secret name"
  default     = "IDPSCIM_SCIMEndpoint"
}

variable "scim_access_token_secret_name" {
  type        = string
  description = "The AWS SSO SCIM AccessToken secret name"
  default     = "IDPSCIM_SCIMAccessToken"
}

variable "gws_groups_filter" {
  type        = string
  description = "The Google Workspace group filter query parameter"
  default     = ""
}

variable "sync_method" {
  type        = string
  description = "The sync method to use"
  default     = "groups"
}

variable "memory_size" {
  type        = number
  description = "The amount of memory to allocate to the Lambda function."
  default     = 256
}

variable "timeout" {
  type        = number
  description = "The amount of time that AWS Lambda service allows a function to run before terminating it."
  default     = 300
}

variable "log_group_name" {
  type        = string
  description = "The name of the CloudWatch log group"
  default     = "/aws/lambda/idp-scim-sync"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the created Lambda function"
  default     = "idp-scim-sync"
}

variable "log_group_retention_days" {
  type        = number
  description = "The number of days you want to keep logs for the lambda function"
  default     = 7
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "semantic_version" {
  type        = string
  description = "The semantic version of the module"
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.semantic_version))
    error_message = "The semantic version must be in the format 'x.y.z'"
  }
}
