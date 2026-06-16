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
}

# S3 bucket for tfstate 
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

# S3 bucket for CloudTrail logs
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

data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  statement {
    sid = "AWSCloudTrailAclCheck"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail.arn]
  }

  statement {
    sid = "AWSCloudTrailWrite"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs_policy" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy.json
}


# CloudTrail 
resource "aws_cloudtrail" "this" {
  name                          = "${var.name_prefix}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.bucket
  enable_log_file_validation    = true
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_logging                = true
  depends_on                    = [aws_s3_bucket_policy.cloudtrail_logs_policy]
}


# ECR repository 
resource "aws_ecr_repository" "app" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true

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

# Group definitions for dev and platform teams
resource "aws_iam_group" "developers" {
  name = "${var.name_prefix}-developers"
}

resource "aws_iam_group" "ops_debug" {
  name = "${var.name_prefix}-ops-debug"
}

#
# Developer Group Permissions
# - can configure app secrets in Secrets Manager
# - can read CloudTrail logs for debugging
#

data "aws_iam_policy_document" "developer_policy" {
  statement {
    sid    = "SecretsManagerAccess"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecrets"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "CloudTrailRead"
    effect = "Allow"

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

resource "aws_iam_policy" "developer_policy" {
  name   = "${var.name_prefix}-developer-policy"
  policy = data.aws_iam_policy_document.developer_policy.json
}

resource "aws_iam_group_policy_attachment" "developers" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.developer_policy.arn
}

#
# Ops Debug Group Permissions (for SREs and Platform team)
# - can access SSM Session Manager for debugging running tasks
# - can read CloudTrail logs for debugging
#

data "aws_iam_policy_document" "ops_policy" {
  statement {
    sid    = "SSMDebug"
    effect = "Allow"

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
    sid    = "CloudTrailRead"
    effect = "Allow"

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

resource "aws_iam_policy" "ops_policy" {
  name   = "${var.name_prefix}-ops-debug-policy"
  policy = data.aws_iam_policy_document.ops_policy.json
}

resource "aws_iam_group_policy_attachment" "ops_debug" {
  group      = aws_iam_group.ops_debug.name
  policy_arn = aws_iam_policy.ops_policy.arn
}