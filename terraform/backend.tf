terraform {
  backend "s3" {
    bucket       = "ecs-journal-tfstate"
    key          = "journal-api/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}