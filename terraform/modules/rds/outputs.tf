output "db_main_address" {
  description = "The hostname of the main RDS instance"
  value       = aws_db_instance.main.address
}

output "db_main_port" {
  description = "The port number of the main RDS instance"
  value       = aws_db_instance.main.port
}

output "db_main_endpoint" {
  description = "The connection endpoint for the main RDS instance (host:port)"
  value       = aws_db_instance.main.endpoint
}

output "db_master_secret_arn" {
  value = aws_db_instance.main.master_user_secret[0].secret_arn
}