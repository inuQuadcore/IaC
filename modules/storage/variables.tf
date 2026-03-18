variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (prod, staging, dev)"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name for file storage"
  type        = string
}
