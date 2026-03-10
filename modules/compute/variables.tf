variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "public_key" {
  description = "SSH public key content"
  type        = string
}

variable "backend_subnet_id" {
  description = "Subnet ID for backend EC2"
  type        = string
}

variable "backend_sg_id" {
  description = "Security group ID for backend EC2"
  type        = string
}

variable "monitoring_subnet_id" {
  description = "Subnet ID for monitoring EC2"
  type        = string
}

variable "monitoring_sg_id" {
  description = "Security group ID for monitoring EC2"
  type        = string
}

variable "backend_instance_type" {
  description = "EC2 instance type for backend"
  type        = string
  default     = "t3.small"
}

variable "monitoring_instance_type" {
  description = "EC2 instance type for monitoring"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID (Ubuntu 24.04 LTS, Singapore)"
  type        = string
  default     = "ami-0497a974f8d5dcef8"
}
