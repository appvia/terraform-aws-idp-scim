data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid    = "AllowIAMThisAccount"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
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
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_kms_key" "this" {
  description = "ipd-scim-sync state bucket kms key"
  policy      = data.aws_iam_policy_document.kms_key_policy.json
}

resource "aws_kms_alias" "this" {
  name          = "alias/idp-scim-sync-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  target_key_id = aws_kms_key.this.key_id
}
