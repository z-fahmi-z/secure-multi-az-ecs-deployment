variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "journal-ecs-cluster"
}

variable "aws_region" {
  description = "AWS region (for CloudWatch Logs)"
  type        = string
}

variable "ecs_sg_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "container_name" {
  description = "Name of the container (for load balancer target group)"
  type        = string
  default     = "journal-api"
}

variable "container_image" {
  description = "Container image to run (e.g. ECR URL)"
  type        = string
  default     = "journal-image:latest"
}

variable "container_user" {
  description = "User (UID) to run the container as"
  type        = string
  default     = "1000"
}

variable "container_cpu" {
  description = "CPU units to allocate to the container"
  type        = number
  default     = 512
}

variable "container_memory" {
  description = "Memory (in MiB) to allocate to the container"
  type        = number
  default     = 1024
}

variable "container_port" {
  description = "Container port to expose"
  type        = number
  default     = 8080
}

variable "desired_count" {
  type        = number
  description = "Number of ECS tasks to run"
  default     = 2
}

variable "bedrock_model_id" {
  description = "Bedrock foundation model ID"
  type        = string
}

variable "bedrock_inference_profile_id" {
  description = "Bedrock inference profile ID (usually 'us.' + model ID)"
  type        = string
}

variable "environments" {
  description = "Static environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "secrets" {
  description = "List of secrets to inject into the container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "secret_arns" {
  description = "List of Secrets Manager ARNs the task execution role can access"
  type        = list(string)
  default     = []
}

variable "target_group_arn" {
  description = "ARN of the load balancer target group to attach the service to"
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
