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

resource "aws_iam_role" "lambda" {
  name               = "idp-scim-sync-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "secretsmanager:GetSecretValue",
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:Encrypt"
    ]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
      aws_secretsmanager_secret.gws_user_email.arn,
      aws_secretsmanager_secret.gws_service_account_file.arn,
      aws_secretsmanager_secret.scim_endpoint.arn,
      aws_secretsmanager_secret.scim_access_token.arn,
      aws_cloudwatch_log_group.lambda_log_group.arn,
      "${aws_cloudwatch_log_group.lambda_log_group.arn}:*",
      aws_kms_key.this.arn
    ]
  }
}

resource "aws_iam_policy" "lambda" {
  name        = "idp-scim-sync-lambda-policy"
  description = "IAM policy for idp-scim-sync Lambda function"
  policy      = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda.arn
  role       = aws_iam_role.lambda.name
}
