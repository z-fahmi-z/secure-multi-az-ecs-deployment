variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "journal"
}

variable "owner" {
  description = "Owner name for tagging"
  type        = string
  default     = "zulfahmi"
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "development"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnet_cidrs" {
  description = "private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "database_subnet_cidrs" {
  description = "database subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.5.0/24"]
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "journaldb"
}

variable "db_user" {
  description = "Database username"
  type        = string
  default     = "postgres"
}