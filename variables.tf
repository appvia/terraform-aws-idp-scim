

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

variable "state_file_key" {
  type        = string
  description = "The key 'file' where the state data will be stored"
  default     = "data/state.json"
}

variable "groups_filter" {
  type        = string
  description = "The Google Workspace group filter query parameter"
  default     = "Name:Cloud*" # Default filter to get all groups that start with 'Cloud'
}

variable "sync_method" {
  type        = string
  description = "The sync method to use"
  default     = "groups"
}

variable "cloudwatch_logs_kms_key_id" {
  type        = string
  description = "The ID of the KMS key to use for encrypting CloudWatch Logs"
  default     = null
}

variable "cloudwatch_logs_retention_in_days" {
  type        = number
  description = "The number of days to retain CloudWatch Logs"
  default     = 7
}

variable "cloudwatch_logs_class" {
  type        = string
  description = "The class of CloudWatch Logs log group to create (e.g. standard or infrequent access)"
  default     = "STANDARD"
}

variable "lambda_runtime" {
  type        = string
  description = "The runtime environment for the Lambda function."
  default     = "provided.al2"
}

variable "lambda_timeout" {
  type        = number
  description = "The amount of time (in seconds) that the Lambda function has to run before it is terminated."
  default     = 300
}

variable "lambda_memory_size" {
  type        = number
  description = "The amount of memory to allocate to the Lambda function."
  default     = 256
}

variable "name" {
  type        = string
  description = "Name of the created Lambda function"
  default     = "lz-idp-scim"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "semantic_version" {
  type        = string
  description = "The semantic version of the module"
  default     = "0.30.1"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.semantic_version))
    error_message = "The semantic version must be in the format 'x.y.z'"
  }
}
