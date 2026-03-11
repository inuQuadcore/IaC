resource "aws_key_pair" "everybuddy" {
  # key_name을 "server-key"로 고정
  # 이름 바꾸면 AWS에서 기존 키페어 삭제 후 재생성 → EC2 접근 불가
  key_name   = "server-key"
  public_key = var.public_key

  tags = {
    Name = "${var.project_name}-ssh-key"
  }
}

resource "aws_instance" "monitoring" {
  ami           = var.ami_id
  instance_type = var.monitoring_instance_type

  subnet_id                   = var.monitoring_subnet_id
  vpc_security_group_ids      = [var.monitoring_sg_id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.everybuddy.key_name

  tags = {
    Name = "${var.project_name}-monitoring"
  }
}

# ============================================================
# Private Backend Server (private-app-a, AZ-a)
# Spring Boot 앱 서버 — ALB 뒤에 위치, 공인 IP 없음
# ============================================================
resource "aws_instance" "private_backend" {
  ami           = var.ami_id
  instance_type = var.backend_instance_type

  subnet_id              = var.private_backend_subnet_id
  vpc_security_group_ids = [var.private_backend_sg_id]
  key_name               = aws_key_pair.everybuddy.key_name

  tags = {
    Name = "${var.project_name}-private-backend"
  }
}

# ============================================================
# Bastion Server (public-b, AZ-b)
# Private EC2 접근을 위한 Jump Host
# ============================================================
resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = var.bastion_instance_type

  subnet_id                   = var.bastion_subnet_id
  vpc_security_group_ids      = [var.bastion_sg_id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.everybuddy.key_name

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

resource "aws_eip" "bastion" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-bastion-eip"
  }
}

resource "aws_eip_association" "bastion" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion.id
}
