variable "fqdn" {
  description = "Primary domain name for the ACM certificate (e.g. app.vammy.org)"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID for DNS validation"
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
