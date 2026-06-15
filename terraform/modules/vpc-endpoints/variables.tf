variable "vpc_id" {
  description = "ID of the VPC where endpoints will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for interface endpoints"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "List of private route table IDs for gateway endpoints"
  type        = list(string)
}

variable "database_subnet_ids" {
  description = "List of database subnet IDs for interface endpoints"
  type        = list(string)
}

variable "vpc_endpoint_sg_ids" {
  description = "List of security group IDs to attach to interface endpoints"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS region where endpoints will be created"
  type        = string
}

variable "name_prefix" {
  description = "Name prefix for naming resources"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}