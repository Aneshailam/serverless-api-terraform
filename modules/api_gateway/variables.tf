variable "api_name" {
  type = string
}

variable "routes" {
  description = "Map of route key (for example 'GET /items') to the Lambda that handles it"
  type = map(object({
    function_name = string
    invoke_arn    = string
  }))
}

variable "cors_allow_origins" {
  type    = list(string)
  default = ["*"]
}

variable "throttling_burst_limit" {
  type    = number
  default = 20
}

variable "throttling_rate_limit" {
  type    = number
  default = 10
}
