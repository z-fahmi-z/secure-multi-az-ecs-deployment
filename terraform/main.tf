resource "random_id" "deployment" {
  byte_length = 4
}

locals {
  label = "${local.prefix}-${random_id.deployment.hex}"
}

module "vpc" {
  source                = "./modules/vpc"
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  availability_zones    = var.availability_zones
  aws_region            = var.aws_region

  label        = local.label
  default_tags = local.default_tags
}