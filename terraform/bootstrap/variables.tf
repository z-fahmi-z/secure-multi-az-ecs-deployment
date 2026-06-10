variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name_prefix" {
  type    = string
  default = "ecs-journal"
}

variable "cloudtrail_log_prefix" {
  type    = string
  default = "journal-logs"
}

variable "ecr_repository_name" {
  type    = string
  default = "journal-repository"
}