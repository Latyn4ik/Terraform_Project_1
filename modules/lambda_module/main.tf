terraform {
  required_version = ">= 1.0.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.63.0"
    }
  }
}

data "aws_region" "region" {}
data "aws_caller_identity" "identity" {}
