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

# RDS Initialization

# Lambda IAM Role and Policies
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_init_role" {
  name               = "${var.name_prefix}-lambda-init-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-lambda-init-role"
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_init_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "lambda_init_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [aws_db_instance.main.master_user_secret[0].secret_arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda_init_policy" {
  name   = "${var.name_prefix}-lambda-init-policy"
  role   = aws_iam_role.lambda_init_role.id
  policy = data.aws_iam_policy_document.lambda_init_policy.json
}

# Lambda Function 
resource "aws_lambda_function" "rds_initializer" {
  filename         = "${path.module}/lambda/lambda_pg_init_deploy.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/lambda_pg_init_deploy.zip")
  function_name    = "${var.name_prefix}-rds-initializer"
  role             = aws_iam_role.lambda_init_role.arn
  handler          = "pg_init.lambda_handler"
  runtime          = var.lambda_runtime
  architectures    = ["arm64"]
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  vpc_config {
    subnet_ids         = var.db_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }

  environment {
    variables = {
      DB_NAME    = var.db_name
      DB_USER    = var.db_user
      DB_HOST    = aws_db_instance.main.address
      DB_PORT    = tostring(var.db_port)
      SECRET_ARN = aws_db_instance.main.master_user_secret[0].secret_arn
    }
  }

  depends_on = [
    aws_db_instance.main,
    aws_iam_role_policy_attachment.lambda_vpc_access
  ]

  timeouts {
    create = "10m"
    update = "10m"
    delete = "20m" # Wait for ENI deletion
  }

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-rds-initializer"
  })
}

# Lambda Invocation
resource "aws_lambda_invocation" "initialize_database" {
  function_name = aws_lambda_function.rds_initializer.function_name
  input = jsonencode({
    timestamp = timestamp()
  })

  depends_on = [aws_lambda_function.rds_initializer]

  lifecycle {
    create_before_destroy = true
  }
}