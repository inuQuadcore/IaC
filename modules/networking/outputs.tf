output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "igw_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "public_subnet_ids" {
  description = "Map of public subnet IDs (key = subnet identifier)"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "private_app_subnet_ids" {
  description = "Map of private app subnet IDs (key = subnet identifier)"
  value       = { for k, v in aws_subnet.private_app : k => v.id }
}

output "private_db_subnet_ids" {
  description = "Map of private DB subnet IDs (key = subnet identifier)"
  value       = { for k, v in aws_subnet.private_db : k => v.id }
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.main.id
}

output "nat_gateway_ip" {
  description = "NAT Gateway public IP (고정 IP - 외부에 화이트리스팅 요청 시 사용)"
  value       = aws_eip.nat.public_ip
}
