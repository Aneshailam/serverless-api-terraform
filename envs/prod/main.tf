locals {
  name = "${var.project}-${var.environment}"
}

module "dynamodb" {
  source = "../../modules/dynamodb"

  table_name             = "${local.name}-items"
  point_in_time_recovery = var.enable_pitr
}

module "create_item" {
  source = "../../modules/lambda"

  function_name         = "${local.name}-create-item"
  source_dir            = "${path.root}/../../lambda/create_item"
  memory_size           = var.lambda_memory_size
  log_retention_days    = var.log_retention_days
  environment_variables = { TABLE_NAME = module.dynamodb.table_name }
  dynamodb_table_arn    = module.dynamodb.table_arn
  dynamodb_actions      = ["dynamodb:PutItem"]
}

module "get_items" {
  source = "../../modules/lambda"

  function_name         = "${local.name}-get-items"
  source_dir            = "${path.root}/../../lambda/get_items"
  memory_size           = var.lambda_memory_size
  log_retention_days    = var.log_retention_days
  environment_variables = { TABLE_NAME = module.dynamodb.table_name }
  dynamodb_table_arn    = module.dynamodb.table_arn
  dynamodb_actions      = ["dynamodb:Scan"]
}

module "delete_item" {
  source = "../../modules/lambda"

  function_name         = "${local.name}-delete-item"
  source_dir            = "${path.root}/../../lambda/delete_item"
  memory_size           = var.lambda_memory_size
  log_retention_days    = var.log_retention_days
  environment_variables = { TABLE_NAME = module.dynamodb.table_name }
  dynamodb_table_arn    = module.dynamodb.table_arn
  dynamodb_actions      = ["dynamodb:DeleteItem"]
}

module "api" {
  source = "../../modules/api_gateway"

  api_name               = "${local.name}-api"
  throttling_burst_limit = var.throttling_burst_limit
  throttling_rate_limit  = var.throttling_rate_limit

  routes = {
    "POST /items" = {
      function_name = module.create_item.function_name
      invoke_arn    = module.create_item.invoke_arn
    }
    "GET /items" = {
      function_name = module.get_items.function_name
      invoke_arn    = module.get_items.invoke_arn
    }
    "DELETE /items/{id}" = {
      function_name = module.delete_item.function_name
      invoke_arn    = module.delete_item.invoke_arn
    }
  }
}

module "frontend" {
  source = "../../modules/frontend"

  name_prefix   = local.name
  frontend_dir  = "${path.root}/../../frontend"
  api_url       = module.api.api_url
  price_class   = var.cloudfront_price_class
  force_destroy = var.force_destroy_frontend
}
