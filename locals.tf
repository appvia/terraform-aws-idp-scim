locals {
  ## The current account ID 
  account_id = data.aws_caller_identity.current.account_id
}