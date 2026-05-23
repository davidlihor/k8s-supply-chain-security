terraform {
  backend "s3" {
    bucket         = "supply-chain-tfstate-405483480335-eu-central-1-an"
    key            = "dev/terraform.tfstate"
    region         = "eu-central-1"
    use_lockfile   = true
    encrypt        = true
  }
}
