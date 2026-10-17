terraform {
  backend "s3" {
    bucket       = "terraform-state-siva-unique-20261015"
    key          = "vpc-webservers/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
