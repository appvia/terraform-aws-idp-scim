## Find the current caller identity and region using AWS data sources
data "aws_caller_identity" "current" {}
## Find the current region using AWS data sources
data "aws_region" "current" {}
