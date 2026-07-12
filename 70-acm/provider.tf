terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.48.0"
    }
  }
   # remote state storage location
  backend "s3" {
    bucket         = "remote-state-ven-dev"
    key            = "roboshop-acm.tfstate" # key means naming the statefile.     <name>.tfstate
    region         = "us-east-1"
    encrypt        = true # Enables server-side encryption of the state file in S3
    use_lockfile   = true # Enables native S3 state locking (Terraform 1.10+)
  }

}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

