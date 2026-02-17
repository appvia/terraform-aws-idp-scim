
locals {
  ## List of secrets to provision with secret manager
  secrets = {
    "service_account" = {
      name        = format("%s-gws-service-account", var.name)
      description = "The secret that contains the Google Workspace service account credentials for the SCIM sync Lambda function"
    },
    "username" = {
      name        = format("%s-gws-username", var.name)
      description = "The secret that contains the Google Workspace service account email for the SCIM sync Lambda function"
    },
    "endpoint" = {
      name        = format("%s-scim-endpoint", var.name)
      description = "The secret that contains the AWS SSO SCIM endpoint for the SCIM sync Lambda function"
    },
    "token" = {
      name        = format("%s-scim-token", var.name)
      description = "The secret that contains the AWS SSO SCIM access token for the SCIM sync Lambda function"
    },
  }
  ## 
  secret_arns = [
    for secret in aws_secretsmanager_secret.secrets : secret.arn
  ]
}

## Craft an IAM policy document for the Lambda function
data "aws_iam_policy_document" "lambda" {
  statement {
    sid    = "AllowKMS"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
    ]
    resources = [
      module.kms.key_arn,
    ]
  }

  statement {
    sid    = "AllowS3"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]
    resources = [
      module.log_bucket.s3_bucket_arn,
      format("%s/*", module.log_bucket.s3_bucket_arn),
    ]
  }

  statement {
    sid    = "AllowSecretsManager"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = local.secret_arns
  }
}


## Provision the secrets in secret manager
resource "aws_secretsmanager_secret" "secrets" {
  for_each = local.secrets

  name        = each.value.name
  description = each.value.description
  tags        = var.tags
}

## Provision the bucket for the Lambda function to store the SCIM sync state, with server-side encryption using the KMS key we created
module "log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.10.0"

  allowed_kms_key_arn                   = module.kms.key_arn
  attach_access_log_delivery_policy     = true
  attach_cloudtrail_log_delivery_policy = true
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true
  bucket                                = var.name
  control_object_ownership              = true
  force_destroy                         = true
  tags                                  = var.tags

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = module.kms.key_id
      }
    }
  }

  versioning = {
    enabled = true
  }
}

## Provision the KMS key and alias for encrypting the S3 bucket
module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "4.2.0"

  aliases                 = [var.name]
  deletion_window_in_days = 30
  description             = "Used to encrypt the S3 bucket for the IDP SCIM sync Lambda function"
  key_administrators      = [format("arn:aws:iam::%s:root", local.account_id)]
  key_owners              = [format("arn:aws:iam::%s:root", local.account_id)]
  tags                    = var.tags

  ## Grant Lambda permissions to use the KMS key, with the 
  ## caller id is restricted to the account to prevent cross-account access
  grants = {
    lambda = {
      name              = format("%s-lambda-grant", var.name)
      grantee_principal = format("arn:aws:iam::%s:root", local.account_id)
      operations = [
        "Decrypt",
        "DescribeKey",
        "Encrypt",
        "GenerateDataKey",
        "ReEncryptFrom",
        "ReEncryptTo",
      ]
      constraints = [
        {
          encryption_context_subset = {
            "aws:CallerAccount" = local.account_id
          }
        }
      ]
    }
  }
}

## Lambda function that used to handle the SCIM sync between AWS SSO and Google Workspace
module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.2.0"

  architectures                = ["arm64"]
  function_name                = var.name
  function_tags                = var.tags
  description                  = "Used to handle the SCIM sync between AWS SSO and Google Workspace"
  handler                      = "bootstrap"
  hash_extra                   = filebase64sha256("${path.module}/dist/${var.semantic_version}/bootstrap.zip")
  memory_size                  = var.lambda_memory_size
  runtime                      = var.lambda_runtime
  tags                         = merge(var.tags, { "Name" = var.name })
  timeout                      = var.lambda_timeout
  trigger_on_package_timestamp = false
  create_package               = false
  local_existing_package       = "${path.module}/dist/${var.semantic_version}/bootstrap.zip"

  ## Environment variables for the Lambda function
  environment_variables = {
    IDPSCIM_AWS_S3_BUCKET_KEY                    = var.state_file_key
    IDPSCIM_AWS_S3_BUCKET_NAME                   = module.log_bucket.s3_bucket_id
    IDPSCIM_AWS_SCIM_ACCESS_TOKEN_SECRET_NAME    = aws_secretsmanager_secret.secrets["token"].arn
    IDPSCIM_AWS_SCIM_ENDPOINT_SECRET_NAME        = aws_secretsmanager_secret.secrets["endpoint"].arn
    IDPSCIM_GWS_GROUPS_FILTER                    = var.groups_filter
    IDPSCIM_GWS_SERVICE_ACCOUNT_FILE_SECRET_NAME = aws_secretsmanager_secret.secrets["service_account"].arn
    IDPSCIM_GWS_USER_EMAIL_SECRET_NAME           = aws_secretsmanager_secret.secrets["username"].arn
    IDPSCIM_LOG_FORMAT                           = "json"
    IDPSCIM_LOG_LEVEL                            = var.log_level
    IDPSCIM_SYNC_METHOD                          = var.sync_method
  }

  ## Lambda Role
  create_role                   = true
  role_name                     = var.name
  role_tags                     = var.tags
  role_force_detach_policies    = true
  role_permissions_boundary     = null
  role_maximum_session_duration = 3600
  role_path                     = "/"

  ## IAM Policy
  attach_policy_json            = true
  attach_network_policy         = false
  attach_cloudwatch_logs_policy = true
  attach_tracing_policy         = true
  policy_json                   = data.aws_iam_policy_document.lambda.json

  ## Cloudwatch Logs
  cloudwatch_logs_tags              = var.tags
  cloudwatch_logs_kms_key_id        = var.cloudwatch_logs_kms_key_id
  cloudwatch_logs_retention_in_days = var.cloudwatch_logs_retention_in_days
  cloudwatch_logs_log_group_class   = var.cloudwatch_logs_class
}

# Add a trigger to the lambda function to run it every 5 minutes
resource "aws_cloudwatch_event_rule" "this" {
  description         = "This rule will trigger the Lambda function every 5 minutes."
  name                = format("%s-schedule", var.name)
  schedule_expression = var.schedule_expression
  tags                = var.tags
}

## Grant permissions for the EventBridge rule to invoke the Lambda function
resource "aws_cloudwatch_event_target" "this" {
  arn  = module.lambda_function.lambda_function_arn
  rule = aws_cloudwatch_event_rule.this.name
}

## Grant permissions for the EventBridge rule to invoke the Lambda function
resource "aws_lambda_permission" "this" {
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
  statement_id  = "AllowExecutionFromCloudWatch"
}
