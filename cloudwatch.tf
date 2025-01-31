resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = var.log_group_name
  retention_in_days = var.log_group_retention_days
}

resource "aws_cloudwatch_log_stream" "lambda_log_stream" {
  name           = split("/", var.log_group_name)[length(split("/", var.log_group_name)) - 1]
  log_group_name = aws_cloudwatch_log_group.lambda_log_group.name
}
