output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The VPC ID"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "The IDs of the private subnets"
}

output "database_subnet_ids" {
  value       = module.vpc.database_subnet_ids
  description = "The IDs of the database subnets"
}

output "ecs_deploy_role_arn" {
  value = module.ecs_deploy_role.role_arn
}