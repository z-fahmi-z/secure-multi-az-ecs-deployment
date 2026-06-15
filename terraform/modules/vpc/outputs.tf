output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The ID of the VPC"
}

output "vpc_cidr" {
  value       = aws_vpc.this.cidr_block
  description = "The CIDR block of the VPC"
}

output "private_subnet_ids" {
  value       = [for s in aws_subnet.private : s.id]
  description = "The IDs of the private subnets"
}

output "private_route_table_ids" {
  value       = [for rt in aws_route_table.private_rt : rt.id]
  description = "The IDs of the private route tables"
}

output "database_subnet_ids" {
  value       = [for s in aws_subnet.database : s.id]
  description = "The IDs of the database subnets"
}