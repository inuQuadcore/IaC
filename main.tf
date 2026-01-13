# ============================================================
# Provider 설정
# ============================================================
# AWS와 통신하기 위한 설정
# - profile: AWS CLI 프로파일 이름 (기본값: "default")
# - region: 리소스를 생성할 AWS 리전
provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"  # 싱가포르
}

# ============================================================
# VPC (Virtual Private Cloud)
# ============================================================
# 여러분만의 가상 네트워크 공간
# - 10.0.0.0/16 = 10.0.0.0 ~ 10.0.255.255 (65,536개 IP 주소)
# - enable_dns_hostnames: EC2에 DNS 이름 자동 할당
# - enable_dns_support: VPC 내부 DNS 쿼리 지원
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "everybuddy-vpc"
  }
}

# ============================================================
# Internet Gateway (인터넷 게이트웨이)
# ============================================================
# VPC와 인터넷을 연결하는 통로
# 이게 없으면 EC2가 인터넷에 접속할 수 없음
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id  # 위에서 만든 VPC에 연결

  tags = {
    Name = "everybuddy-igw"
  }
}

# ============================================================
# Public Subnet (퍼블릭 서브넷)
# ============================================================
# VPC 내부의 네트워크 구역
# - 10.0.1.0/24 = 10.0.1.0 ~ 10.0.1.255 (256개 IP)
# - availability_zone: 물리적 데이터센터 위치
# - map_public_ip_on_launch: EC2 생성 시 자동으로 Public IP 부여
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "everybuddy-public-subnet"
  }
}

# Public Subnet 2 - Monitoring
resource "aws_subnet" "public_monitoring" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "everybuddy-public-subnet-monitoring"
  }
}

# ============================================================
# Route Table (라우팅 테이블)
# ============================================================
# 네트워크 트래픽을 어디로 보낼지 결정하는 규칙
# - 0.0.0.0/0 = 모든 인터넷 트래픽
# - gateway_id = 인터넷 게이트웨이로 전달
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"           # 목적지: 모든 인터넷
    gateway_id = aws_internet_gateway.main.id  # 경로: IGW 통과
  }

  tags = {
    Name = "everybuddy-public-rt"
  }
}

# ============================================================
# Route Table Association (라우팅 테이블 연결)
# ============================================================
# 서브넷과 라우팅 테이블을 연결
# "이 서브넷은 이 라우팅 규칙을 따른다"
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# 모니터링 서버 서브넷 - 라우팅 테이블 연결
resource "aws_route_table_association" "public_monitoring" {
  subnet_id      = aws_subnet.public_monitoring.id
  route_table_id = aws_route_table.public.id
}


# ============================================================
# EC2 Instance (가상 서버)
# ============================================================

# EC2 Instance - Backend Server 
resource "aws_instance" "backend" {
  # AMI: Amazon Machine Image (운영체제 이미지)
  ami           = "ami-0497a974f8d5dcef8"  # Ubuntu 24.04 LTS (Singapore)
  
  # 인스턴스 타입: 서버 사양 (CPU, 메모리)
  # t3.micro = 2 vCPU, 1GB RAM (무료 티어)
  instance_type = "t3.micro"

  # 네트워크 설정
  subnet_id                   = aws_subnet.public.id  # 위에서 만든 서브넷에 배치
  vpc_security_group_ids      = [aws_security_group.backend.id]  # 방화벽 규칙
  associate_public_ip_address = true  # 공인 IP 자동 할당
  
  # SSH 접속용 키페어
  key_name = aws_key_pair.everybuddy.key_name

  tags = {
    Name = "everybuddy-backend"
  }
}

# EC2 Instance - Monitoring Server 
resource "aws_instance" "monitoring" {
  ami           = "ami-0497a974f8d5dcef8"  # Ubuntu 24.04 LTS (Singapore)
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.public_monitoring.id
  vpc_security_group_ids      = [aws_security_group.monitoring.id]
  associate_public_ip_address = true
  
  key_name = aws_key_pair.everybuddy.key_name

  tags = {
    Name = "everybuddy-monitoring"
  }
}

# ============================================================
# SSH Key Pair (SSH 키페어)
# ============================================================
# EC2에 SSH로 접속하기 위한 키
# - serverkey.pub (공개키)를 AWS에 등록
# - serverkey (개인키)는 로컬에만 보관
resource "aws_key_pair" "everybuddy" {
  key_name   = "server-key"
  public_key = file("${path.module}/serverkey.pub")  # ⭐ 이렇게 수정!
  
  tags = {
    Name = "everybuddy-ssh-key"
  }
}