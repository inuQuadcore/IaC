variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "alb_arn" {
  description = "ALB ARN to associate WAF with"
  type        = string
}
