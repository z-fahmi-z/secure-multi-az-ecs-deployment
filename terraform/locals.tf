locals {
  default_tags = {
    Project = var.project_name
    Env     = var.environment
    Owner   = var.owner
  }
  prefix = "${var.project_name}-${var.environment}"
}
