resource "aws_db_subnet_group" "rds_main" {
  name        = "${var.name_prefix}-rds-main-subnet-group"
  description = "Subnet group for primary RDS instance"
  subnet_ids  = var.db_subnet_ids
}

resource "aws_db_instance" "main" {
  identifier                  = var.rds_main_identifier
  engine                      = var.db_engine
  engine_version              = var.db_engine_version
  instance_class              = var.db_instance_class
  username                    = var.db_user
  manage_master_user_password = true
  db_name                     = var.db_name
  port                        = var.db_port
  storage_type                = var.storage_type
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.max_allocated_storage
  storage_encrypted           = var.storage_encrypted
  publicly_accessible         = var.publicly_accessible
  skip_final_snapshot         = true

  # Network config
  multi_az                = var.multi_az
  apply_immediately       = var.apply_immediately
  backup_retention_period = var.backup_retention_period
  db_subnet_group_name    = aws_db_subnet_group.rds_main.name
  vpc_security_group_ids  = var.security_group_ids

  timeouts {
    update = "30m"
  }

  lifecycle {
    prevent_destroy = false
  }
}