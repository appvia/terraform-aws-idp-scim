
## Craft an IAM policy document for the KMS key
data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid    = "AllowKMS"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:root",
        data.aws_caller_identity.current.arn
      ]
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow access for Key Administrators"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowAWSLambdaToRetrieveKMSKey"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:Generate*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.account_id]
    }
  }
}

## Provision the KMS key and alias for encrypting the S3 bucket
resource "aws_kms_key" "this" {
  description = "Used to encrypt the S3 bucket for the IDP SCIM sync Lambda function"
  policy      = data.aws_iam_policy_document.kms_key_policy.json
  tags        = var.tags
}

## Create an alias for the KMS key
resource "aws_kms_alias" "this" {
  name          = format("alias/%s", var.name)
  target_key_id = aws_kms_key.this.key_id
}
