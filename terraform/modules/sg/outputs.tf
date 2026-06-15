output "vpc_endpoint_sg_id" {
  description = "Security Group ID for VPC Endpoints"
  value       = aws_security_group.vpc_endpoints.id
}

output "alb_sg_id" {
  description = "Security Group ID for Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "ecs_sg_id" {
  description = "Security Group ID for ECS Tasks"
  value       = aws_security_group.ecs.id
}

output "rds_sg_id" {
  description = "Security Group ID for RDS"
  value       = aws_security_group.rds.id
}

output "lambda_sg_id" {
  description = "Security Group ID for RDS Initialization Lambda"
  value       = aws_security_group.lambda_init.id
}