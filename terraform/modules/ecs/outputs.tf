output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.this.id
}