variable "project" {
  type    = string
  default = "serverless-api"
}

variable "environment" {
  type = string
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "lambda_memory_size" {
  type = number
}

variable "log_retention_days" {
  type = number
}

variable "enable_pitr" {
  type = bool
}

variable "cloudfront_price_class" {
  type = string
}

variable "force_destroy_frontend" {
  type = bool
}

variable "throttling_burst_limit" {
  type = number
}

variable "throttling_rate_limit" {
  type = number
}
