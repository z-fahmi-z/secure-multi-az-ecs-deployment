output "vpc_endpoint_ids" {
  description = "Map of VPC endpoint IDs"
  value = {
    bedrock_runtime = try(aws_vpc_endpoint.bedrock_runtime.id, null)
    secrets_manager = try(aws_vpc_endpoint.secrets_manager.id, null)
    ecr_api         = try(aws_vpc_endpoint.ecr_api.id, null)
    ecr_dkr         = try(aws_vpc_endpoint.ecr_dkr.id, null)
    s3              = try(aws_vpc_endpoint.s3.id, null)
  }
}