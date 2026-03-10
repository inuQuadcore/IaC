variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_db_subnet_ids" {
  description = "Map of private DB subnet IDs"
  type        = map(string)
}

variable "allowed_sg_ids" {
  description = "RDS 3306 접근을 허용할 Security Group ID 목록"
  type        = list(string)
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "everybuddy"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "RDS master password (TF_VAR_db_password 환경변수로 주입)"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0"
}

variable "db_allocated_storage" {
  description = "Storage size in GB"
  type        = number
  default     = 20
}
