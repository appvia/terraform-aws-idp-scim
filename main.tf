
## Provision the Lambda function and its dependencies
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = format("/aws/lambda/%s", var.name)
  retention_in_days = var.log_group_retention_days
}

## Provision the secret for the Google Workspace account file
resource "aws_secretsmanager_secret" "gws_service_account_file" {
  name = var.gws_service_account_file_secret_name
}

## Provision the secret for the Google Workspace user email
resource "aws_secretsmanager_secret" "gws_user_email" {
  name = var.gws_user_email_secret_name
}

## Provision the secret for the SCIM endpoint
resource "aws_secretsmanager_secret" "scim_endpoint" {
  name = var.scim_endpoint_secret_name
}

## Provision the secret for the SCIM access token
resource "aws_secretsmanager_secret" "scim_access_token" {
  name = var.scim_access_token_secret_name
}

## Provision the lambda function and its dependencies
resource "aws_lambda_function" "this" {
  architectures = ["arm64"]
  description   = "This Lambda function will sync the AWS SSO groups and users with the Google Workspace directory."
  function_name = var.name
  handler       = "bootstrap"
  memory_size   = var.memory_size
  role          = aws_iam_role.lambda.arn
  runtime       = "provided.al2"
  timeout       = var.timeout

  environment {
    variables = {
      IDPSCIM_AWS_S3_BUCKET_KEY                    = var.state_file_key
      IDPSCIM_AWS_S3_BUCKET_NAME                   = aws_s3_bucket.this.bucket
      IDPSCIM_AWS_SCIM_ACCESS_TOKEN_SECRET_NAME    = aws_secretsmanager_secret.scim_access_token.arn
      IDPSCIM_AWS_SCIM_ENDPOINT_SECRET_NAME        = aws_secretsmanager_secret.scim_endpoint.arn
      IDPSCIM_GWS_GROUPS_FILTER                    = var.gws_groups_filter
      IDPSCIM_GWS_SERVICE_ACCOUNT_FILE_SECRET_NAME = aws_secretsmanager_secret.gws_service_account_file.arn
      IDPSCIM_GWS_USER_EMAIL_SECRET_NAME           = aws_secretsmanager_secret.gws_user_email.arn
      IDPSCIM_LOG_FORMAT                           = var.log_format
      IDPSCIM_LOG_LEVEL                            = var.log_level
      IDPSCIM_SYNC_METHOD                          = var.sync_method
    }
  }

  filename         = "${path.module}/dist/${var.semantic_version}/bootstrap.zip"
  source_code_hash = filebase64sha256("${path.module}/dist/${var.semantic_version}/bootstrap.zip")
}

# Add a trigger to the lambda function to run it every 5 minutes
resource "aws_cloudwatch_event_rule" "this" {
  description         = "This rule will trigger the Lambda function every 5 minutes."
  name                = format("%s-schedule", var.name)
  schedule_expression = var.schedule_expression
}

## Grant permissions for the EventBridge rule to invoke the Lambda function
resource "aws_cloudwatch_event_target" "this" {
  arn  = aws_lambda_function.this.arn
  rule = aws_cloudwatch_event_rule.this.name
}

## Grant permissions for the EventBridge rule to invoke the Lambda function
resource "aws_lambda_permission" "this" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
  statement_id  = "AllowExecutionFromCloudWatch"
}
