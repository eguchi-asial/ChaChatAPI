terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  # profile = "chachat-api"
  profile = "chachat-api"
  region  = "ap-northeast-1"
}
