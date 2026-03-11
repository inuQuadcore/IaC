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

  public_subnets = {
    backend = { cidr = "10.0.1.0/24", az = "ap-southeast-1a" }
    monitoring = { cidr = "10.0.2.0/24", az = "ap-southeast-1a" }
    b = { cidr = "10.0.3.0/24", az = "ap-southeast-1b" }
  }

  private_app_subnets = {
    a = { cidr = "10.0.11.0/24", az = "ap-southeast-1a" }
    b = { cidr = "10.0.12.0/24", az = "ap-southeast-1b" }
  }

  private_db_subnets = {
    a = { cidr = "10.0.21.0/24", az = "ap-southeast-1a" }
    b = { cidr = "10.0.22.0/24", az = "ap-southeast-1b" }
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
# DNS
# Route53 Hosted Zone (everybuddy.cloud)
# ============================================================
module "dns" {
  source       = "./modules/dns"
  project_name = var.project_name
  domain_name  = var.domain_name
}

# ============================================================
# ALB
# Application Load Balancer + ACM + Route53 A record
# ============================================================
module "alb" {
  source       = "./modules/alb"
  project_name = var.project_name
  vpc_id       = module.networking.vpc_id

  public_subnet_ids = [
    module.networking.public_subnet_ids["backend"],
    module.networking.public_subnet_ids["b"],
  ]

  domain_name   = var.domain_name
  zone_id       = module.dns.zone_id
  backend_sg_id = module.security.backend_sg_id
}

# ALB Target Group에 현재 Backend EC2 등록
# 4단계에서 Private EC2로 교체 예정
resource "aws_lb_target_group_attachment" "backend" {
  target_group_arn = module.alb.target_group_arn
  target_id        = module.compute.backend_instance_id
  port             = 8080
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
