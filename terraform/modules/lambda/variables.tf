variable "db_subnet_ids" {
  description = "Subnet IDs for the RDS instance"
  type        = list(string)
}

variable "db_user" {
  description = "Database user ARN"
  type        = string
}

variable "db_name" {
  description = "Database name ARN"
  type        = string
}

variable "db_host" {
  description = "Database host"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "db_master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the RDS master user credentials"
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "python3.13"
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda function"
  type        = number
  default     = 300
}

variable "lambda_memory_size" {
  description = "Memory size for the Lambda function"
  type        = number
  default     = 256
}

variable "lambda_sg_id" {
  description = "Security group ID for the Lambda function"
  type        = string
}

variable "name_prefix" {
  description = "Project wide prefix for resource names"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}