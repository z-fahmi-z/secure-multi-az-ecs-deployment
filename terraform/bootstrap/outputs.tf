output "terraform_state_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "terraform_state_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
}

output "cloudtrail_log_bucket_name" {
  value = aws_s3_bucket.cloudtrail.bucket
}

output "cloudtrail_log_bucket_arn" {
  value = aws_s3_bucket.cloudtrail.arn
}

output "cloudtrail_log_prefix" {
  value = var.cloudtrail_log_prefix
}

output "cloudtrail_name" {
  value = aws_cloudtrail.this.name
}

output "cloudtrail_s3_log_path" {
  value = "s3://${aws_s3_bucket.cloudtrail.bucket}/${var.cloudtrail_log_prefix}/"
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "ecr_repository_name" {
  value = aws_ecr_repository.app.name
}

output "ecr_repository_arn" {
  value = aws_ecr_repository.app.arn
}

output "developers_group_arn" {
  description = "ARN of the developers group for IAM policies and references"
  value       = aws_iam_group.developers.arn
}

output "ops_debug_group_arn" {
  description = "ARN of the operations debug group"
  value       = aws_iam_group.ops_debug.arn
}

output "ecr_push_role_arn" {
  value = module.ecr_push_role.role_arn
}