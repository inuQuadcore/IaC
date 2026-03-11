variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB (최소 2개 AZ)"
  type        = list(string)
}

variable "domain_name" {
  description = "Root domain name (e.g. everybuddy.cloud)"
  type        = string
}

variable "zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
}

variable "backend_sg_id" {
  description = "Backend EC2 Security Group ID (ALB → 8080 허용 규칙 추가용)"
  type        = string
}
