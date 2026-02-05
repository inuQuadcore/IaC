# VPC 정보
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

# 서브넷 정보
output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.public.id
}

# 보안 그룹 정보
output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.backend.id
}

# SSH 키페어 정보
output "key_pair_name" {
  description = "SSH Key Pair Name"
  value       = aws_key_pair.everybuddy.key_name
}

# EC2 정보
output "ec2_instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.backend.id
}

output "ec2_public_ip" {
  description = "EC2 Public IP (Elastic IP)"
  value       = aws_eip.backend.public_ip
}

output "ec2_public_dns" {
  description = "EC2 Public DNS"
  value       = aws_instance.backend.public_dns
}

# SSH 접속 명령어
output "ssh_command" {
  description = "SSH 접속 명령어"
  value       = "ssh -i ~/.ssh/everybuddy-key.pem ubuntu@${aws_eip.backend.public_ip}"
}

# 전체 요약
output "summary" {
  description = "Infrastructure Summary"
  value = {
    vpc_id            = aws_vpc.main.id
    ec2_id            = aws_instance.backend.id
    public_ip         = aws_eip.backend.public_ip
    security_group_id = aws_security_group.backend.id
    key_name          = aws_key_pair.everybuddy.key_name
  }
}

# S3 버킷 정보
output "s3_bucket_name" {
  description = "S3 버킷 이름"
  value       = aws_s3_bucket.everybuddy_files.id
}

output "s3_bucket_arn" {
  description = "S3 버킷 ARN"
  value       = aws_s3_bucket.everybuddy_files.arn
}

output "s3_bucket_region" {
  description = "S3 버킷 리전"
  value       = aws_s3_bucket.everybuddy_files.region
}

# 모니터링 서버 정보
output "monitoring_instance_id" {
  description = "Monitoring EC2 Instance ID"
  value       = aws_instance.monitoring.id
}

output "monitoring_public_ip" {
  description = "Monitoring EC2 Public IP"
  value       = aws_instance.monitoring.public_ip
}

output "monitoring_public_dns" {
  description = "Monitoring EC2 Public DNS"
  value       = aws_instance.monitoring.public_dns
}

output "monitoring_ssh_command" {
  description = "SSH 접속 명령어 (Monitoring)"
  value       = "ssh -i ~/.ssh/everybuddy-key.pem ubuntu@${aws_instance.monitoring.public_ip}"
}

# Grafana 접속 URL
output "grafana_url" {
  description = "Grafana 접속 URL"
  value       = "http://${aws_instance.monitoring.public_ip}:3000"
}

# Prometheus 접속 URL
output "prometheus_url" {
  description = "Prometheus 접속 URL"
  value       = "http://${aws_instance.monitoring.public_ip}:9090"
}