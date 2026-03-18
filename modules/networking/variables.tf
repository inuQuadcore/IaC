variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnets: key = identifier, value = { cidr, az }"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "private_app_subnets" {
  description = "Private app subnets (Spring Boot, FastAPI): key = identifier, value = { cidr, az }"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "private_db_subnets" {
  description = "Private DB subnets (RDS): key = identifier, value = { cidr, az }"
  type = map(object({
    cidr = string
    az   = string
  }))
}
