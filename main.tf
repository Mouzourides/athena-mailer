terraform {
  backend "s3" {
    region = "eu-west-1"
    bucket = "nikmouz-aws-terraform-state"
    key = "athena-mailer"
  }
}

provider "aws" {
  region = "eu-west-1"
  version = "~> 3.4.0"
}

provider "archive" {
  version = "~> 1.3.0"
}

provider "null" {
  version = "~> 2.1.2"
}
