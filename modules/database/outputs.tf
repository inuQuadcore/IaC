output "rds_endpoint" {
  description = "RDS 접속 endpoint (host:port 형태)"
  value       = aws_db_instance.main.endpoint
}

output "rds_host" {
  description = "RDS host (endpoint에서 포트 제외)"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.main.port
}

output "rds_db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "rds_username" {
  description = "RDS master username"
  value       = aws_db_instance.main.username
}

output "rds_sg_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds.id
}
