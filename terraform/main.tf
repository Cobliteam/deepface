terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.48"
    }
  }
  required_version = "< 1.7.0"
}

provider "aws" {
  # Default provider
  profile = "cobli-tech"
  region  = "us-east-1"
  default_tags {
    tags = local.tags
  }
}
