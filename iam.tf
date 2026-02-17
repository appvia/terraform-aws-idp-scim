
## Craft an assume role policy document for the Lambda function
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    effect = "Allow"
  }
}

## Craft an IAM policy document for the Lambda function
data "aws_iam_policy_document" "lambda" {

  statement {
    sid    = "AllowKMS"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:Encrypt"
    ]
    resources = [
      aws_kms_key.this.arn
    ]
  }

  statement {
    sid    = "AllowS3"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.this.arn,
      format("%s/*", aws_s3_bucket.this.arn),
    ]
  }

  statement {
    sid    = "AllowSecretsManager"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      aws_secretsmanager_secret.gws_service_account_file.arn,
      aws_secretsmanager_secret.gws_user_email.arn,
      aws_secretsmanager_secret.scim_access_token.arn,
      aws_secretsmanager_secret.scim_endpoint.arn,
    ]
  }

  statement {
    sid    = "AllowCloudWatch"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.lambda_log_group.arn,
      format("%s:*", aws_cloudwatch_log_group.lambda_log_group.arn),
    ]
  }
}

## Provision the IAM role and policies for the Lambda function
resource "aws_iam_role" "lambda" {
  name               = var.name
  description        = format("IAM role for the %s Lambda function", var.name)
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.tags
}

## Create the IAM policy for the Lambda function
resource "aws_iam_policy" "lambda" {
  name        = format("%s-policy", var.name)
  description = format("Used by the %s Lambda function to synchronize Identity Center", var.name)
  policy      = data.aws_iam_policy_document.lambda.json
}

## Attach the IAM policy to the Lambda function role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda.arn
  role       = aws_iam_role.lambda.name
}
