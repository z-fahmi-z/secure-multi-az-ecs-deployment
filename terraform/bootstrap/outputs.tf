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

output "developer_role_arn" {
  value = aws_iam_role.developer.arn
}

output "ops_role_arn" {
  value = aws_iam_role.ops_debug.arn
}