resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/idp-scim-sync"
  retention_in_days = var.log_group_retention_days
}

resource "aws_cloudwatch_log_stream" "lambda_log_stream" {
  name           = "idp-scim-sync-log-stream"
  log_group_name = aws_cloudwatch_log_group.lambda_log_group.name
}
