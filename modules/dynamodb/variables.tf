variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "point_in_time_recovery" {
  description = "Enable point-in-time recovery backups"
  type        = bool
  default     = false
}
