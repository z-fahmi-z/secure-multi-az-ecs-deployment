variable "vpc_id" {
  description = "ID of the VPC where the ALB will be deployed"
  type        = string
}

variable "container_port" {
  description = "Port on which the container is listening"
  type        = number
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the ALB"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB (one per AZ)"
  type        = list(string)
}

variable "health_check_path" {
  description = "Path for the ALB health check (e.g. /health)"
  type        = string
  default     = "/docs"
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate to use for the ALB"
  type        = string
}

variable "name_prefix" {
  description = "Project wide label for resource names"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}
