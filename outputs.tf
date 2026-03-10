# DNS
output "route53_name_servers" {
  description = "가비아 네임서버에 입력할 NS 레코드 4개"
  value       = module.dns.name_servers
}

output "route53_zone_id" {
  description = "Route53 Hosted Zone ID"
  value       = module.dns.zone_id
}

# VPC
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.networking.vpc_cidr
}

# EC2 - Backend
output "backend_instance_id" {
  description = "Backend EC2 instance ID"
  value       = module.compute.backend_instance_id
}

output "backend_public_ip" {
  description = "Backend EC2 Elastic IP"
  value       = module.compute.backend_public_ip
}

output "ssh_command" {
  description = "SSH command for backend"
  value       = "ssh -i ./serverkey ubuntu@${module.compute.backend_public_ip}"
}

# EC2 - Monitoring
output "monitoring_instance_id" {
  description = "Monitoring EC2 instance ID"
  value       = module.compute.monitoring_instance_id
}

output "monitoring_public_ip" {
  description = "Monitoring EC2 public IP"
  value       = module.compute.monitoring_public_ip
}

output "monitoring_ssh_command" {
  description = "SSH command for monitoring server"
  value       = "ssh -i ./serverkey ubuntu@${module.compute.monitoring_public_ip}"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "http://${module.compute.monitoring_public_ip}:3000"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://${module.compute.monitoring_public_ip}:9090"
}

# S3
output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.storage.bucket_id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.storage.bucket_arn
}

# Subnets
output "private_app_subnet_ids" {
  description = "Private app subnet IDs"
  value       = module.networking.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "Private DB subnet IDs"
  value       = module.networking.private_db_subnet_ids
}

output "nat_gateway_ip" {
  description = "NAT Gateway 고정 IP (외부 서비스 화이트리스팅 시 사용)"
  value       = module.networking.nat_gateway_ip
}

# RDS
output "rds_endpoint" {
  description = "RDS endpoint (Spring Boot datasource url에 사용)"
  value       = module.database.rds_endpoint
}

output "rds_host" {
  description = "RDS host"
  value       = module.database.rds_host
}

output "rds_db_name" {
  description = "Database name"
  value       = module.database.rds_db_name
}

# EC2 - Bastion
output "bastion_instance_id" {
  description = "Bastion EC2 instance ID"
  value       = module.compute.bastion_instance_id
}

output "bastion_public_ip" {
  description = "Bastion EC2 Elastic IP"
  value       = module.compute.bastion_public_ip
}

output "bastion_ssh_command" {
  description = "SSH command for Bastion server"
  value       = "ssh -i ./serverkey ubuntu@${module.compute.bastion_public_ip}"
}

output "ssh_via_bastion_backend" {
  description = "SSH to backend via Bastion (ProxyJump)"
  value       = "ssh -i ./serverkey -J ubuntu@${module.compute.bastion_public_ip} ubuntu@<backend-private-ip>"
}

# Summary
output "summary" {
  description = "Infrastructure summary"
  value = {
    vpc_id        = module.networking.vpc_id
    backend_ip    = module.compute.backend_public_ip
    monitoring_ip = module.compute.monitoring_public_ip
    bastion_ip    = module.compute.bastion_public_ip
    s3_bucket     = module.storage.bucket_id
    key_name      = module.compute.key_pair_name
  }
}
