variable "github_org" {
  description = "GitHub organization or username that owns the repository allowed to assume this role"
  type        = string
  default     = "z-fahmi-z"
}

variable "github_repo" {
  description = "Repository name only, without org prefix (e.g. 'career-journal-api', not 'myorg/career-journal-api')"
  type        = string
  default     = "journal-starter"
}

variable "github_branch" {
  description = "Branch whose workflow runs are trusted to assume this role via the OIDC subject claim"
  type        = string
  default     = "main"
}

variable "role_name" {
  description = "Name for the IAM role as it will appear in AWS — should describe its purpose (e.g. 'github-ci-ecr-push')"
  type        = string
}

variable "max_session_duration_seconds" {
  description = "Maximum duration, in seconds, an assumed-role STS session remains valid"
  type        = number
  default     = 3600
}

variable "tags" {
  description = "Arbitrary key-value tags applied to the IAM role for cost attribution or ownership tracking"
  type        = map(string)
  default     = {}
}