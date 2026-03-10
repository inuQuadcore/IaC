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
  # 사용 방법:
  # 1. terraform apply 로 아래 state_bucket 리소스 먼저 생성
  # 2. 아래 주석 해제
  # 3. terraform init -migrate-state 실행 (로컬 state → S3 이전)
  #
  # backend "s3" {
  #   bucket  = "everybuddy-terraform-state"
  #   key     = "prod/terraform.tfstate"
  #   region  = "ap-southeast-1"
  #   encrypt = true
  # }
}
