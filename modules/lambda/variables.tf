variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "source_dir" {
  description = "Folder containing the function code"
  type        = string
}

variable "handler" {
  description = "Handler, for example handler.lambda_handler"
  type        = string
  default     = "handler.lambda_handler"
}

variable "runtime" {
  type    = string
  default = "python3.12"
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "timeout" {
  type    = number
  default = 10
}

variable "log_retention_days" {
  type    = number
  default = 14
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "dynamodb_table_arn" {
  description = "ARN of the table this function may access"
  type        = string
}

variable "dynamodb_actions" {
  description = "DynamoDB actions this function is allowed to use"
  type        = list(string)
}
