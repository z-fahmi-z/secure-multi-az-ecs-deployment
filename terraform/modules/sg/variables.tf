variable "alb_ingress_cidr" {
  description = "CIDR blocks allowed to access the ALB."
  type        = string
  default     = "0.0.0.0/0"
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "app_port" {
  description = "Application port that ECS tasks listen on."
  type        = number
  default     = 8080
}

variable "rds_port" {
  description = "Port that RDS listens on."
  type        = number
  default     = 5432
}

variable "aws_region" {
  description = "AWS region for the resources"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Name prefix for naming resources"
  type        = string
}