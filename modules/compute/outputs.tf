output "backend_instance_id" {
  description = "Backend EC2 instance ID"
  value       = aws_instance.backend.id
}

output "backend_public_ip" {
  description = "Backend EC2 Elastic IP"
  value       = aws_eip.backend.public_ip
}

output "backend_public_dns" {
  description = "Backend EC2 public DNS"
  value       = aws_instance.backend.public_dns
}

output "monitoring_instance_id" {
  description = "Monitoring EC2 instance ID"
  value       = aws_instance.monitoring.id
}

output "monitoring_public_ip" {
  description = "Monitoring EC2 public IP"
  value       = aws_instance.monitoring.public_ip
}

output "monitoring_public_dns" {
  description = "Monitoring EC2 public DNS"
  value       = aws_instance.monitoring.public_dns
}

output "key_pair_name" {
  description = "SSH key pair name"
  value       = aws_key_pair.everybuddy.key_name
}
