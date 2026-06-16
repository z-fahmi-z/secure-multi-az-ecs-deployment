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
  aws_region = var.aws_region

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

data "aws_ecr_repository" "journal_api" {
  name = var.ecr_repository_name
}

module "ecs" {
  source             = "./modules/ecs"
  cluster_name       = "${local.name_prefix}-cluster"
  container_name     = var.container_name
  container_image    = "${data.aws_ecr_repository.journal_api.repository_url}:latest"
  container_user     = "1000"
  container_cpu      = 512
  container_memory   = 1024
  container_port     = var.container_port
  desired_count      = 2
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_sg_id          = module.sg.ecs_sg_id
  bedrock_model_id   = var.bedrock_model_id
  aws_region         = var.aws_region

  # Envionment and secrets
  environments = [
    {
      name  = "POSTGRES_USER",
      value = var.db_user
    },
    {
      name  = "POSTGRES_DB",
      value = var.db_name
    },
    {
      name  = "POSTGRES_HOST",
      value = module.rds.db_main_address
    },
    {
      name  = "POSTGRES_PORT"
      value = module.rds.db_main_port
    },
    {
      name  = "CLOUD_NATIVE",
      value = true
    },
    {
      name  = "AWS_REGION",
      value = var.aws_region
    },
    {
      name  = "BEDROCK_MODEL_ID",
      value = var.bedrock_model_id
    }
  ]

  secrets = [
    {
      name      = "POSTGRES_PASSWORD"
      valueFrom = module.rds.db_master_secret_arn
    }
  ]

  secret_arns = [
    module.rds.db_master_secret_arn
  ]

  name_prefix  = local.name_prefix
  default_tags = local.default_tags
}