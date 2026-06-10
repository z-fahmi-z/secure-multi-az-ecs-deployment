data "aws_caller_identity" "current" {}

locals {
  state_bucket_name      = "${var.name_prefix}-tfstate"
  cloudtrail_bucket_name = "${var.name_prefix}-cloudtrail"

  force_destroy = true

  secure_bucket_config = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
    sse_algorithm           = "AES256"
  }

  cloudtrail_log_objects = [
    "${aws_s3_bucket.cloudtrail.arn}/${var.cloudtrail_log_prefix}",
    "${aws_s3_bucket.cloudtrail.arn}/${var.cloudtrail_log_prefix}/*"
  ]

  developer_team_principal_arns = [
    for user in var.developer_team_usernames :
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${user}"
  ]

  sre_team_principal_arns = [
    for user in var.sre_team_usernames :
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${user}"
  ]

  platform_team_principal_arns = [
    for user in var.platform_team_usernames :
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${user}"
  ]
}

#
# S3 bucket for tfstate with versioning and encryption enabled
#

resource "aws_s3_bucket" "terraform_state" {
  bucket        = local.state_bucket_name
  force_destroy = local.force_destroy
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = local.secure_bucket_config.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = local.secure_bucket_config.block_public_acls
  block_public_policy     = local.secure_bucket_config.block_public_policy
  ignore_public_acls      = local.secure_bucket_config.ignore_public_acls
  restrict_public_buckets = local.secure_bucket_config.restrict_public_buckets
}

#
# S3 bucket for CloudTrail logs
#

resource "aws_s3_bucket" "cloudtrail" {
  bucket        = local.cloudtrail_bucket_name
  force_destroy = local.force_destroy
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = local.secure_bucket_config.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket                  = aws_s3_bucket.cloudtrail.id
  block_public_acls       = local.secure_bucket_config.block_public_acls
  block_public_policy     = local.secure_bucket_config.block_public_policy
  ignore_public_acls      = local.secure_bucket_config.ignore_public_acls
  restrict_public_buckets = local.secure_bucket_config.restrict_public_buckets
}

#
# CloudTrail log bucket
# 
resource "aws_cloudtrail" "this" {
  name           = "${var.name_prefix}-trail"
  s3_bucket_name = aws_s3_bucket.cloudtrail.bucket
}

#
# ECR repository for application images
#

resource "aws_ecr_repository" "app" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 50 images"

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 50
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}

#
# Trust policies for dev and platform teams
#

data "aws_iam_policy_document" "developer_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.developer_team_principal_arns
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "ops_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = concat(
        local.sre_team_principal_arns,
        local.platform_team_principal_arns
      )
    }

    actions = ["sts:AssumeRole"]
  }
}


# Developer role 
# - can configure app secrets in Secrets Manager
# - can read CloudTrail logs for debugging

resource "aws_iam_role" "developer" {
  name               = "${var.name_prefix}-developer-secrets-access"
  assume_role_policy = data.aws_iam_policy_document.developer_assume_role.json
}

data "aws_iam_policy_document" "developer_policy" {

  statement {
    sid = "SecretsManagerAccess"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecrets"
    ]

    resources = ["*"]
  }

  statement {
    sid = "CloudTrailRead"

    actions = [
      "cloudtrail:GetTrail",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:LookupEvents",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = concat(
      [aws_s3_bucket.cloudtrail.arn],
      local.cloudtrail_log_objects
    )
  }
}

resource "aws_iam_role_policy" "developer_inline_policy" {
  role   = aws_iam_role.developer.id
  policy = data.aws_iam_policy_document.developer_policy.json
}

# Ops debug role (mainly for SREs and Platform team)
# - can access SSM Session Manager for debugging running tasks
# - can read CloudTrail logs for debugging

resource "aws_iam_role" "ops_debug" {
  name               = "${var.name_prefix}-ops-ssm-debug"
  assume_role_policy = data.aws_iam_policy_document.ops_assume_role.json
}

data "aws_iam_policy_document" "ops_policy" {

  statement {
    sid = "SSMDebug"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "ssm:DescribeParameters",
      "ssm:StartSession",
      "ssm:ResumeSession",
      "ssm:TerminateSession",
      "ssm:DescribeSessions",
      "ssm:SendCommand",
      "ssm:ListCommands",
      "ssm:ListCommandInvocations",
      "ec2:DescribeInstances"
    ]

    resources = ["*"]
  }

  statement {
    sid = "CloudTrailRead"

    actions = [
      "cloudtrail:GetTrail",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:LookupEvents",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = concat(
      [aws_s3_bucket.cloudtrail.arn],
      local.cloudtrail_log_objects
    )
  }
}

resource "aws_iam_role_policy" "ops_inline_policy" {
  role   = aws_iam_role.ops_debug.id
  policy = data.aws_iam_policy_document.ops_policy.json
}