locals {
  name_prefix = "${local.prefix}-${random_id.deployment.hex}"
}

resource "random_id" "deployment" {
  byte_length = 4
}

module "vpc" {
  source                = "./modules/vpc"
  vpc_cidr              = var.vpc_cidr
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  availability_zones    = var.availability_zones
  aws_region            = var.aws_region

  name_prefix  = local.name_prefix
  default_tags = local.default_tags
}

module "sg" {
  source   = "./modules/sg"
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr

  name_prefix  = local.name_prefix
  default_tags = local.default_tags
}

module "vpc_endpoints" {
  source                  = "./modules/vpc-endpoints"
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr                = module.vpc.vpc_cidr
  vpc_endpoint_sg_ids     = [module.sg.vpc_endpoint_sg_id]
  private_subnet_ids      = module.vpc.private_subnet_ids
  private_route_table_ids = module.vpc.private_route_table_ids
  database_subnet_ids     = module.vpc.database_subnet_ids
  aws_region              = var.aws_region

  name_prefix  = local.name_prefix
  default_tags = local.default_tags
}

module "rds" {
  source              = "./modules/rds"
  rds_main_identifier = "${local.name_prefix}-postgres-main"
  db_subnet_ids       = module.vpc.database_subnet_ids
  security_group_ids  = [module.sg.rds_sg_id]
  lambda_sg_id        = module.sg.lambda_sg_id

  # Database configurations
  db_engine         = "postgres"
  db_engine_version = "18.3"
  db_instance_class = "db.t4g.small"
  db_name           = var.db_name
  db_user           = var.db_user

  # For development
  publicly_accessible = true

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true

  multi_az                = true
  apply_immediately       = true
  backup_retention_period = 7

  name_prefix  = local.name_prefix
  default_tags = local.default_tags
}