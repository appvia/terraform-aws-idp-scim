resource "aws_lambda_function" "this" {
  function_name = var.lambda_function_name
  description   = "This Lambda function will sync the AWS SSO groups and users with the Google Workspace directory."
  runtime       = "provided.al2"
  memory_size   = var.memory_size
  timeout       = var.timeout
  handler       = "bootstrap"
  role          = aws_iam_role.lambda.arn
  architectures = ["arm64"]

  environment {
    variables = {
      IDPSCIM_LOG_LEVEL                            = var.log_level
      IDPSCIM_LOG_FORMAT                           = var.log_format
      IDPSCIM_SYNC_METHOD                          = var.sync_method
      IDPSCIM_AWS_S3_BUCKET_NAME                   = aws_s3_bucket.this.bucket
      IDPSCIM_AWS_S3_BUCKET_KEY                    = var.state_file_key
      IDPSCIM_GWS_GROUPS_FILTER                    = var.gws_groups_filter
      IDPSCIM_GWS_USER_EMAIL_SECRET_NAME           = aws_secretsmanager_secret.gws_user_email.arn
      IDPSCIM_GWS_SERVICE_ACCOUNT_FILE_SECRET_NAME = aws_secretsmanager_secret.gws_service_account_file.arn
      IDPSCIM_AWS_SCIM_ENDPOINT_SECRET_NAME        = aws_secretsmanager_secret.scim_endpoint.arn
      IDPSCIM_AWS_SCIM_ACCESS_TOKEN_SECRET_NAME    = aws_secretsmanager_secret.scim_access_token.arn
    }
  }

  filename         = "${path.module}/dist/${var.semantic_version}/bootstrap.zip"
  source_code_hash = filebase64sha256("${path.module}/dist/${var.semantic_version}/bootstrap.zip")
}

# add a trigger to the lambda function to run it every 5 minutes
resource "aws_cloudwatch_event_rule" "this" {
  name                = "idp-scim-sync"
  description         = "This rule will trigger the Lambda function every 5 minutes."
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "this" {
  rule = aws_cloudwatch_event_rule.this.name
  arn  = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}
