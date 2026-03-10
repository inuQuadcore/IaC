# ============================================================
# RDS Security Group
# ============================================================
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS MySQL"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# 허용할 SG 목록을 for_each로 처리
# → 현재: backend SG / 4단계 이후: private app SG 추가
resource "aws_security_group_rule" "rds_mysql" {
  for_each = toset(var.allowed_sg_ids)

  type                     = "ingress"
  description              = "MySQL access from app servers"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rds_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds.id
}

# ============================================================
# DB Subnet Group
# RDS Subnet Group은 최소 2개 AZ 서브넷 필요
# a: RDS 실제 인스턴스 / b: 요구사항 충족용 (빈 서브넷)
# ============================================================
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = values(var.private_db_subnet_ids)

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# ============================================================
# RDS MySQL Instance
# ============================================================
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-mysql"

  engine            = "mysql"
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  allocated_storage = var.db_allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false
  multi_az            = false

  # true = terraform destroy 시 최종 스냅샷 없이 바로 삭제
  # 운영 전환 시 false + final_snapshot_identifier 설정 권장
  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "${var.project_name}-mysql"
  }
}
