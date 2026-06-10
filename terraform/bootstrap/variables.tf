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

variable "developer_team_usernames" {
  type        = list(string)
  description = "List of developer usernames who can assume the developer role"
  default     = ["developer"]
}

variable "sre_team_usernames" {
  type        = list(string)
  description = "List of sre team usernames who can assume the ops role"
  default     = ["sre"]
}

variable "platform_team_usernames" {
  type        = list(string)
  description = "List of platform team usernames who can assume the ops role"
  default     = ["platform"]
}

variable "ecr_repository_name" {
  type    = string
  default = "journal-repository"
}