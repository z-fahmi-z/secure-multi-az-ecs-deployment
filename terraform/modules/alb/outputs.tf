output "alb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "ALB DNS name — used by the route53 module for alias record"
}

output "alb_zone_id" {
  value       = aws_lb.this.zone_id
  description = "ALB hosted zone ID — used by the route53 module alias record"
}

output "target_group_arn" {
  value       = aws_lb_target_group.this.arn
  description = "Target group ARN — wire this into the ECS service module"
}