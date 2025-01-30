resource "aws_secretsmanager_secret" "gws_service_account_file" {
  name = var.gws_service_account_file_secret_name
}

resource "aws_secretsmanager_secret" "gws_user_email" {
  name = var.gws_user_email_secret_name
}

resource "aws_secretsmanager_secret" "scim_endpoint" {
  name = var.scim_endpoint_secret_name
}

resource "aws_secretsmanager_secret" "scim_access_token" {
  name = var.scim_access_token_secret_name
}
