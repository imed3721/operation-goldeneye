terraform {
  backend "s3" {
    bucket       = "goldeneye-tfstate-demi"
    key          = "operation-goldeneye/dev/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
