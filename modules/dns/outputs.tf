output "zone_id" {
  description = "Route53 Hosted Zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "Route53 NS records (가비아에 입력할 네임서버 4개)"
  value       = aws_route53_zone.main.name_servers
}
