terraform {
  backend "s3" {
    bucket       = "terraform-rds-siva-20261015"
    key          = "vpc-rds/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
