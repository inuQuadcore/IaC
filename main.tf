# ============================================================
# Provider
# ============================================================
provider "aws" {
  profile = "default"
  region  = var.aws_region
}

# ============================================================
# Networking
# VPC, Internet Gateway, Public Subnets, Route Tables
# ============================================================
module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name

  # ── Public Subnets ──────────────────────────────────────────
  # backend    (AZ-a): 기존 Backend EC2 임시 거주 + NAT GW + ALB
  # monitoring (AZ-a): Monitoring EC2 (이전 없이 그대로 유지)
  # b          (AZ-b): Bastion Server + ALB 멀티AZ용
  public_subnets = {
    backend = {
      cidr = "10.0.1.0/24"
      az   = "ap-southeast-1a"
    }
    monitoring = {
      cidr = "10.0.2.0/24"
      az   = "ap-southeast-1a"
    }
    b = {
      cidr = "10.0.3.0/24"
      az   = "ap-southeast-1b"
    }
  }

  # ── Private App Subnets ─────────────────────────────────────
  # Spring Boot, FastAPI EC2가 올라갈 서브넷
  private_app_subnets = {
    a = {
      cidr = "10.0.11.0/24"
      az   = "ap-southeast-1a"
    }
    b = {
      cidr = "10.0.12.0/24"
      az   = "ap-southeast-1b"
    }
  }

  # ── Private DB Subnets ──────────────────────────────────────
  # a: RDS 실제 인스턴스
  # b: RDS Subnet Group 요구사항용 (빈 서브넷)
  private_db_subnets = {
    a = {
      cidr = "10.0.21.0/24"
      az   = "ap-southeast-1a"
    }
    b = {
      cidr = "10.0.22.0/24"
      az   = "ap-southeast-1b"
    }
  }
}

# ============================================================
# Security Groups
# ============================================================
module "security" {
  source       = "./modules/security"
  project_name = var.project_name
  vpc_id       = module.networking.vpc_id
}

# ============================================================
# Compute
# EC2 Instances, Key Pair, Elastic IP
# ============================================================
module "compute" {
  source       = "./modules/compute"
  project_name = var.project_name

  public_key = file("${path.root}/serverkey.pub")

  backend_subnet_id    = module.networking.public_subnet_ids["backend"]
  backend_sg_id        = module.security.backend_sg_id
  monitoring_subnet_id = module.networking.public_subnet_ids["monitoring"]
  monitoring_sg_id     = module.security.monitoring_sg_id
  bastion_subnet_id    = module.networking.public_subnet_ids["b"]
  bastion_sg_id        = module.security.bastion_sg_id

  backend_instance_type    = var.backend_instance_type
  monitoring_instance_type = var.monitoring_instance_type
  bastion_instance_type    = var.bastion_instance_type
}

# ============================================================
# Storage
# S3 Bucket (file storage)
# ============================================================
module "storage" {
  source       = "./modules/storage"
  project_name = var.project_name
  environment  = var.environment
  bucket_name  = var.files_bucket_name
}

# ============================================================
# Database
# RDS MySQL (Private DB Subnet)
# ============================================================
# ============================================================
# DNS
# Route53 Hosted Zone (everybuddy.cloud)
# ============================================================
module "dns" {
  source       = "./modules/dns"
  project_name = var.project_name
  domain_name  = var.domain_name
}

# ============================================================
# Database
# RDS MySQL (Private DB Subnet)
# ============================================================
module "database" {
  source       = "./modules/database"
  project_name = var.project_name
  vpc_id       = module.networking.vpc_id

  private_db_subnet_ids = module.networking.private_db_subnet_ids

  # 현재: backend EC2 SG만 허용
  # 4단계(Spring Boot Private 전환) 이후: private app SG 추가 예정
  allowed_sg_ids = [module.security.backend_sg_id]

  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = var.db_instance_class
}
