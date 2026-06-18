variable "hosted_zone_name" {
  description = "Name of the Route53 hosted zone (e.g. vammy.org)"
  type        = string
}

variable "record_name" {
  description = "Name of the DNS record to be created (e.g. app)"
  type        = string
  default     = "deployed-journal-app"
}

variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  type        = string
}

variable "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}