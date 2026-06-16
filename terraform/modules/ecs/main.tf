locals {
  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = var.environments
      secrets     = var.secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = var.container_name
        }
      }
    }
  ])
}

resource "aws_ecs_cluster" "this" {
  name = "${var.name_prefix}-cluster"

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-cluster"
  })
}

# IAM: Task Execution Role

## Trust Policy
data "aws_iam_policy_document" "task_execution_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution" {
  name               = "${var.name_prefix}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume_role.json

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-task-execution-role"
  })
}

## Inline Tasks Execution Policy
resource "aws_iam_role_policy_attachment" "task_execution_managed" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

## Secrets Permissions
data "aws_iam_policy_document" "task_execution_secrets" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = var.secret_arns
  }
}

resource "aws_iam_role_policy" "task_execution_secrets" {
  name   = "${var.name_prefix}-task-execution-secrets"
  role   = aws_iam_role.task_execution.id
  policy = data.aws_iam_policy_document.task_execution_secrets.json
}

# IAM: Task Role

## Trust Policy
data "aws_iam_policy_document" "task_role_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_role" {
  name               = "${var.name_prefix}-task-role"
  assume_role_policy = data.aws_iam_policy_document.task_role_assume.json

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-task-role"
  })
}

## Bedrock Permissions
data "aws_iam_policy_document" "task_role_bedrock" {
  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
    ]
    resources = [
      "arn:aws:bedrock:${var.aws_region}::foundation-model/${var.bedrock_model_id}",
    ]
  }
}

resource "aws_iam_role_policy" "task_role_bedrock" {
  name   = "${var.name_prefix}-task-role-bedrock"
  role   = aws_iam_role.task_role.id
  policy = data.aws_iam_policy_document.task_role_bedrock.json
}

## SSM channel permissions

data "aws_iam_policy_document" "task_role_ssm" {
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "task_role_ssm" {
  name   = "${var.name_prefix}-task-role-ssm"
  role   = aws_iam_role.task_role.id
  policy = data.aws_iam_policy_document.task_role_ssm.json
}

# Task Definition
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name_prefix}-task"
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task_role.arn
  container_definitions    = local.container_definitions

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-task"
  })
}

# ECS Service
resource "aws_ecs_service" "this" {
  name            = "${var.name_prefix}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  enable_execute_command = true
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-service"
  })

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# CloudWatch 
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.name_prefix}"
  retention_in_days = 7

  tags = merge(var.default_tags, {
    Name = "${var.name_prefix}-log-group"
  })
}