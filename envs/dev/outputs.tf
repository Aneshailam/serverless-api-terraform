output "api_url" {
  value = module.api.api_url
}

output "website_url" {
  value = module.frontend.cloudfront_url
}

output "table_name" {
  value = module.dynamodb.table_name
}
