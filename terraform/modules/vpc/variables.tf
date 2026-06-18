variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones to use for subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR"
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "Database subnet CIDR"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Project wide prefix for resource names"
  type        = string
}
