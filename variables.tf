variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "everybuddy"
}

variable "environment" {
  description = "Environment (prod, staging, dev)"
  type        = string
  default     = "prod"
}

variable "backend_instance_type" {
  description = "EC2 instance type for backend server"
  type        = string
  default     = "t3.small"
}

variable "monitoring_instance_type" {
  description = "EC2 instance type for monitoring server"
  type        = string
  default     = "t3.micro"
}

variable "files_bucket_name" {
  description = "S3 bucket name for file storage"
  type        = string
  default     = "everybuddy-files-prod-20250103"
}
