variable "name_prefix" {
  type = string
}

variable "frontend_dir" {
  description = "Folder containing index.html"
  type        = string
}

variable "api_url" {
  type = string
}

variable "price_class" {
  type    = string
  default = "PriceClass_100"
}

variable "force_destroy" {
  description = "Allow terraform destroy to delete a non-empty bucket"
  type        = bool
  default     = false
}
