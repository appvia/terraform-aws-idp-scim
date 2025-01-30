output "lambda_function_arn" {
  value       = aws_lambda_function.this.arn
  description = "The ARN of the Lambda function"
}

output "bucket_name" {
  value       = aws_s3_bucket.this.bucket
  description = "The name of the S3 bucket"
}

output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "The ARN of the S3 bucket"
}

output "kms_key_id" {
  value       = aws_kms_key.this.id
  description = "The ID of the KMS key"
}

output "kms_key_arn" {
  value       = aws_kms_key.this.arn
  description = "The ARN of the KMS key"
}
