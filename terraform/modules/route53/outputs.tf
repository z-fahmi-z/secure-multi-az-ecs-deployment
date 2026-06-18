output "hosted_zone_id" {
  value       = data.aws_route53_zone.this.zone_id
  description = "Zone ID — used by the ACM module for DNS validation"
}

output "fqdn" {
  value       = aws_route53_record.alb_alias.fqdn
  description = "Fully-qualified domain name of the application"
}