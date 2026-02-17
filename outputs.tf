output "lambda_function_arn" {
  value       = module.lambda_function.lambda_function_arn
  description = "The ARN of the Lambda function"
}

output "bucket_name" {
  value       = module.log_bucket.s3_bucket_id
  description = "The name of the S3 bucket"
}

output "bucket_arn" {
  value       = module.log_bucket.s3_bucket_arn
  description = "The ARN of the S 3 bucket"
}

output "kms_key_id" {
  value       = module.kms.key_id
  description = "The ID of the KMS key"
}

output "kms_key_arn" {
  value       = module.kms.key_arn
  description = "The ARN of the KMS key"
}
