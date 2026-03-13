terraform {
  required_version = ">= 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # ============================================================
  # S3 Remote State Backend
  # ============================================================
  backend "s3" {
    bucket  = "everybuddy-terraform-state"
    key     = "prod/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}
