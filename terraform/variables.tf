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

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.4.0/24"]
}

variable "private_subnet_cidrs" {
  description = "private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.5.0/24"]
}

variable "database_subnet_cidrs" {
  description = "database subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.6.0/24"]
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

variable "bedrock_model_id" {
  description = "Bedrock foundation model ID"
  type        = string
  default     = "deepseek.v3.2"
}

variable "container_port" {
  description = "Port on which the application container listens"
  type        = number
  default     = 8080
}

variable "container_name" {
  description = "Name of the application container"
  type        = string
  default     = "journal-app"
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository for application images"
  type        = string
  default     = "journal-repository"
}