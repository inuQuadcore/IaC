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

# ============================================================
# Security Group - Monitoring Server
# ============================================================
resource "aws_security_group" "monitoring" {
  name        = "everybuddy-monitoring-sg"
  description = "Security group for monitoring server"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "everybuddy-monitoring-sg"
  }
}

# ============================================================
# Monitoring Server Ingress Rules
# ============================================================

# SSH
resource "aws_security_group_rule" "monitoring_ssh" {
  type              = "ingress"
  description       = "SSH access"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # TODO: 나중에 내 IP로 제한
  security_group_id = aws_security_group.monitoring.id
}

# Grafana (3000)
resource "aws_security_group_rule" "monitoring_grafana" {
  type              = "ingress"
  description       = "Grafana web UI"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # TODO: 팀원 IP로 제한
  security_group_id = aws_security_group.monitoring.id
}

# Prometheus (9090) - 선택적
resource "aws_security_group_rule" "monitoring_prometheus" {
  type              = "ingress"
  description       = "Prometheus web UI"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # TODO: 내 IP로 제한
  security_group_id = aws_security_group.monitoring.id
}

# Loki (3100) - 백엔드 서버에서만 접근
resource "aws_security_group_rule" "monitoring_loki" {
  type                     = "ingress"
  description              = "Loki push endpoint from backend"
  from_port                = 3100
  to_port                  = 3100
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.backend.id  # 백엔드 서버만 허용
  security_group_id        = aws_security_group.monitoring.id
}

# Egress - 모든 아웃바운드 허용
resource "aws_security_group_rule" "monitoring_egress" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.monitoring.id
}

# Node Exporter (9100) - 모니터링 서버에서만 접근
resource "aws_security_group_rule" "backend_node_exporter" {
  type                     = "ingress"
  description              = "Node Exporter metrics for Prometheus"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.monitoring.id  # 모니터링 서버만 허용
  security_group_id        = aws_security_group.backend.id
}

# Spring Boot Actuator (8080) - 모니터링 서버에서 메트릭 수집
# 이미 8080이 열려있으니 추가 규칙 불필요, 하지만 명시적으로 분리하려면:
resource "aws_security_group_rule" "backend_actuator_prometheus" {
  type                     = "ingress"
  description              = "Spring Boot Actuator metrics for Prometheus"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.monitoring.id
  security_group_id        = aws_security_group.backend.id
}