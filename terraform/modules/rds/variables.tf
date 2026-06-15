variable "db_subnet_ids" {
  description = "List of subnet IDs for RDS instances"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for RDS database"
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

variable "name_prefix" {
  description = "Project wide prefix for resource names"
  type        = string
}

variable "rds_main_identifier" {
  description = "Identifier for the main RDS instance"
  type        = string
  default     = "main"
}

variable "db_engine" {
  description = "Database engine (postgres, mysql, etc.)"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "16.3"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "publicly_accessible" {
  description = "Whether the RDS instance should be publicly accessible"
  type        = bool
  default     = false
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage for autoscaling"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type (gp2, gp3, io1)"
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply changes immediately"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
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

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}