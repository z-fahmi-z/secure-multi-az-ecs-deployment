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
    resources = [var.db_master_user_secret_arn]
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

#
# Lambda Function 
#
resource "aws_lambda_function" "rds_initializer" {
  filename         = "${path.module}/src/lambda_pg_init_deploy.zip"
  source_code_hash = filebase64sha256("${path.module}/src/lambda_pg_init_deploy.zip")
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
      DB_HOST    = var.db_host
      DB_PORT    = tostring(var.db_port)
      SECRET_ARN = var.db_master_user_secret_arn
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_init_policy,
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