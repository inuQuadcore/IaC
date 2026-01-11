# ============================================================
# Security Group (보안 그룹 - 방화벽)
# ============================================================
# EC2 인스턴스에 대한 인바운드/아웃바운드 트래픽 제어
resource "aws_security_group" "backend" {
  name        = "everybuddy-backend-sg"
  description = "Security group for backend server"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "everybuddy-backend-sg"
  }
}

# ============================================================
# Ingress Rules (인바운드 규칙 - 들어오는 트래픽)
# ============================================================

# SSH (22번 포트) - 서버 접속용
resource "aws_security_group_rule" "backend_ssh" {
  type              = "ingress"
  description       = "SSH access"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # 모든 IP 허용 (실무에서는 본인 IP만 허용 권장)
  security_group_id = aws_security_group.backend.id
}

# HTTP (80번 포트) - 웹 서비스
resource "aws_security_group_rule" "backend_http" {
  type              = "ingress"
  description       = "HTTP access"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.backend.id
}

# HTTPS (443번 포트) - 보안 웹 서비스
resource "aws_security_group_rule" "backend_https" {
  type              = "ingress"
  description       = "HTTPS access"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.backend.id
}

# Spring Boot (8080번 포트) - 애플리케이션
resource "aws_security_group_rule" "backend_app" {
  type              = "ingress"
  description       = "Spring Boot application"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.backend.id
}

# ============================================================
# Egress Rules (아웃바운드 규칙 - 나가는 트래픽)
# ============================================================

# 모든 아웃바운드 트래픽 허용
resource "aws_security_group_rule" "backend_egress" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"  # 모든 프로토콜
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.backend.id
}
