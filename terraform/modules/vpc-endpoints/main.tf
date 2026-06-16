# Bedrock
resource "aws_vpc_endpoint" "bedrock_runtime" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.bedrock-runtime"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = var.vpc_endpoint_sg_ids
  private_dns_enabled = true

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-bedrock-runtime-endpoint"
  })
}

# ASM
resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = var.vpc_endpoint_sg_ids
  private_dns_enabled = true

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-secrets-manager-endpoint"
  })
}

# ECR 
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = var.vpc_endpoint_sg_ids
  private_dns_enabled = true

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-ecr-api-endpoint"
  })
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = var.vpc_endpoint_sg_ids
  private_dns_enabled = true

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-ecr-dkr-endpoint"
  })
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-ecr-private-s3-endpoint"
  })
}

# CloudWatch Logs
resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = var.vpc_endpoint_sg_ids
  private_dns_enabled = true

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-cloudwatch-logs-endpoint"
  })
}

# SSM 
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = var.vpc_endpoint_sg_ids
  private_dns_enabled = true

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-ssm-endpoint"
  })
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = var.vpc_endpoint_sg_ids
  private_dns_enabled = true

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-ssm-messages-endpoint"
  })
}

resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = var.vpc_endpoint_sg_ids
  private_dns_enabled = true

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-ec2-messages-endpoint"
  })
}