output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The ID of the VPC"
}

output "public_subnet_ids" {
  value       = [for s in aws_subnet.public : s.id]
  description = "The IDs of the public subnets"
}

output "private_subnet_ids" {
  value       = [for s in aws_subnet.private : s.id]
  description = "The IDs of the private subnets"
}

output "database_subnet_ids" {
  value       = [for s in aws_subnet.database : s.id]
  description = "The IDs of the database subnets"
}