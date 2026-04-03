# Infrastructure Changelog

everybuddy 인프라 변경 이력 (AWS ap-southeast-1 / Terraform)

---

## v1.0.0 — 초기 인프라 구성
**날짜:** 2026-01-11
**커밋:** `83470e6` Initial commit

### 추가된 리소스
| 리소스 | 이름 | 상세 |
|--------|------|------|
| VPC | everybuddy-vpc | 10.0.0.0/16, DNS 활성화 |
| Internet Gateway | everybuddy-igw | VPC 연결 |
| Subnet (public) | everybuddy-public-subnet | 10.0.1.0/24, ap-southeast-1a |
| Route Table | everybuddy-public-rt | 0.0.0.0/0 → IGW |
| EC2 | everybuddy-backend | t3.micro, Ubuntu 24.04 LTS |
| Key Pair | server-key | serverkey.pub |
| Security Group | everybuddy-backend-sg | 22/80/443/8080 인바운드 허용 |
| S3 Bucket | everybuddy-files-prod-20250103 | 파일 스토리지, 퍼블릭 액세스 차단, CORS 설정 |

---

## v1.1.0 — 모니터링 서버 추가
**날짜:** 2026-01-13
**커밋:** `94e09c8` Feat: 모니터링 서버 추가

### 추가된 리소스
| 리소스 | 이름 | 상세 |
|--------|------|------|
| Subnet (public) | everybuddy-public-subnet-monitoring | 10.0.2.0/24, ap-southeast-1a |
| EC2 | everybuddy-monitoring | t3.micro, Ubuntu 24.04 LTS |
| Security Group | everybuddy-monitoring-sg | 22/3000/9090 전체 허용, 3100(Loki)은 백엔드 SG만 |

### 모니터링 스택 (서버 내 Docker)
- Grafana :3000
- Prometheus :9090 — 백엔드 Node Exporter(9100), Spring Boot Actuator(8080) 스크랩
- Loki :3100 — 백엔드 Promtail로부터 로그 수신

---

## v1.2.0 — 백엔드 서버 스펙 업그레이드 + EIP 추가
**날짜:** 2026-02-05
**커밋:** `9532433` Feat: backend server upgrade

### 변경 내용
- EC2 인스턴스 타입: `t3.micro` → `t3.small` (2 vCPU, 2GB RAM)
- Elastic IP 추가: 재시작 후에도 고정 IP 유지 (`18.136.148.40`)
- EIP ↔ EC2 연결 (aws_eip_association)

---

## v2.0.0 — Terraform 모듈화 + Private 전환 준비
**날짜:** 2026-03-10
**커밋:** `c499eeb` 모듈화 및 private 전환 준비

### 구조 변경
단일 tf 파일 구조 → 모듈 분리

```
modules/
├── networking/   # VPC, Subnet, IGW, NAT GW, Route Table
├── security/     # Security Groups
├── compute/      # EC2, Key Pair, EIP
├── storage/      # S3
└── database/     # (준비)
```

### 추가된 리소스
| 리소스 | 이름 | 상세 |
|--------|------|------|
| Subnet (private-app-a) | everybuddy-private-app-subnet-a | 10.0.11.0/24, ap-southeast-1a |
| Subnet (private-app-b) | everybuddy-private-app-subnet-b | 10.0.12.0/24, ap-southeast-1b |
| Subnet (private-db-a) | everybuddy-private-db-subnet-a | 10.0.21.0/24, ap-southeast-1a |
| Subnet (private-db-b) | everybuddy-private-db-subnet-b | 10.0.22.0/24, ap-southeast-1b |

### 기타
- GitHub Issue/PR 템플릿 추가
- variables.tf, versions.tf, outputs.tf 분리

---

## v2.1.0 — RDS MySQL 생성
**날짜:** 2026-03-10
**커밋:** `7b7c063` Feat: RDS mysql 생성

### 추가된 리소스
| 리소스 | 이름 | 상세 |
|--------|------|------|
| RDS | everybuddy-mysql | MySQL 8.0, db.t3.micro |
| DB Subnet Group | - | private-db-a, private-db-b (Multi-AZ 준비) |
| Security Group | everybuddy-rds-sg | 3306 — 백엔드 SG만 허용 |

**엔드포인트:** `everybuddy-mysql.cno2sciake0k.ap-southeast-1.rds.amazonaws.com:3306`

---

## v2.2.0 — Bastion 서버 + Route53 추가
**날짜:** 2026-03-10
**커밋:** `6029567` Feat: Bastion + Route53

### 추가된 리소스
| 리소스 | 이름 | 상세 |
|--------|------|------|
| EC2 (Bastion) | everybuddy-bastion | t3.nano, public-b (ap-southeast-1b), EIP: 47.130.252.75 |
| Security Group | everybuddy-bastion-sg | 22 전체 허용 (GitHub Actions CI/CD용) |
| Route53 Hosted Zone | everybuddy.cloud | Zone ID: Z101242833QT25CARKQBT |
| modules/dns | - | Route53 모듈 신규 추가 |

### 네트워크 접근 구조
```
인터넷 → Bastion (public-b) → SSH ProxyJump → Private Backend
GitHub Actions → Bastion → Private EC2 배포
```

---

## v2.3.0 — ALB + ACM (HTTPS) 구성
**날짜:** 2026-03-11
**커밋:** `51e3972` Feat: alb 배치

### 추가된 리소스
| 리소스 | 이름 | 상세 |
|--------|------|------|
| ALB | everybuddy-alb | internet-facing, ap-southeast-1a/1b |
| ACM Certificate | everybuddy.cloud | DNS 검증, ISSUED |
| Target Group | everybuddy-backend-tg | HTTP:8080, health check /actuator/health |
| ALB Listener (80) | - | HTTP → HTTPS 리다이렉트 |
| ALB Listener (443) | - | HTTPS → Target Group 포워딩 |
| Route53 A Record | api.everybuddy.cloud | ALB Alias |
| modules/alb | - | ALB 모듈 신규 추가 |

**ALB DNS:** `everybuddy-alb-2066495541.ap-southeast-1.elb.amazonaws.com`

---

## v2.4.0 — 백엔드 서버 Private 전환
**날짜:** 2026-03-11
**커밋:** `c8d4175` Refector: public -> private 서버 이전

### 변경 내용
- 기존 Public Backend EC2 → 신규 **Private Backend EC2** (`everybuddy-private-backend`)
  - 서브넷: `public-backend` → `private-app-a` (10.0.11.0/24)
  - Public IP 없음, NAT GW로 아웃바운드 처리
  - Private IP: `10.0.11.108`
- Security Group 신규 추가: `everybuddy-private-backend-sg`
  - 8080: ALB SG만 허용
  - 22: Bastion SG만 허용
- ALB Target Group에 Private EC2:8080 등록
- Compute 모듈에서 Public Backend 제거, Private Backend 추가

### 인터넷 → 백엔드 트래픽 흐름
```
클라이언트 → ALB (HTTPS:443) → Private EC2 (HTTP:8080)
```

---

## v2.5.0 — 모니터링 Security Group 보완
**날짜:** 2026-03-13
**커밋:** `dc9cfd7` Feat: monitoring 보안그룹 설정

### 변경 내용
- 모니터링 서버 SG에 Private Backend → Monitoring 방향 규칙 추가
  - Node Exporter(9100): 모니터링 SG → Private Backend SG
  - Promtail → Loki(3100) 경로 명시적 허용

---

## v2.6.0 — S3 Remote Backend 설정
**날짜:** 2026-03-13
**커밋:** `86c091d` Feat: S3 Remote Backend 설정

### 변경 내용
- Terraform State를 로컬에서 S3로 이관
- S3 버킷: `everybuddy-terraform-state`
- versions.tf에 backend 블록 추가

### 효과
- State 파일 팀 공유 가능
- State 파일 로컬 유실 방지

---

## v2.6.1 — 보안: .claude/ gitignore 처리
**날짜:** 2026-03-18
**커밋:** `9ae62b2` Security: .claude/ gitignore 추가 및 tracking 제거

### 변경 내용
- `.claude/settings.local.json`에 서버 IP 등 인프라 정보 포함 확인
- git tracking 제거 (`git rm --cached`)
- `.gitignore`에 `.claude/` 디렉토리 추가

---

## 현재 인프라 구성 요약

```
ap-southeast-1 (Singapore)
│
├── VPC: everybuddy-vpc (10.0.0.0/16)
│   │
│   ├── Public Subnets
│   │   ├── public-backend     (10.0.1.0/24, AZ-a)  ← NAT GW 위치
│   │   ├── public-monitoring  (10.0.2.0/24, AZ-a)  ← Monitoring EC2
│   │   └── public-b           (10.0.3.0/24, AZ-b)  ← Bastion EC2, ALB
│   │
│   ├── Private App Subnets
│   │   ├── private-app-a      (10.0.11.0/24, AZ-a) ← Backend EC2
│   │   └── private-app-b      (10.0.12.0/24, AZ-b)
│   │
│   └── Private DB Subnets
│       ├── private-db-a       (10.0.21.0/24, AZ-a) ← RDS MySQL
│       └── private-db-b       (10.0.22.0/24, AZ-b)
│
├── EC2 Instances
│   ├── everybuddy-private-backend  (t3.small,  10.0.11.108, private)
│   ├── everybuddy-monitoring       (t3.micro,  13.250.55.151, public)
│   └── everybuddy-bastion          (t3.nano,   47.130.252.75, public)
│
├── ALB: everybuddy-alb (internet-facing)
│   └── api.everybuddy.cloud → HTTPS:443 → Private Backend:8080
│
├── RDS: everybuddy-mysql (MySQL 8.0, db.t3.micro, private-db-a)
│
├── S3
│   ├── everybuddy-files-prod-20250103  (파일 스토리지)
│   └── everybuddy-terraform-state      (Terraform Remote Backend)
│
├── NAT Gateway (public-backend AZ-a, EIP: 47.130.218.236)
│   └── Private 서브넷 아웃바운드 인터넷 허용
│
├── ACM: everybuddy.cloud (ISSUED)
└── Route53: everybuddy.cloud (Hosted Zone)
    └── api.everybuddy.cloud → ALB Alias
```

---

## 예정 작업

| 단계 | 내용 | 상태 |
|------|------|------|
| 5단계 | FastAPI 서버 Private 배포 | 예정 |
| 6단계 | GPU 서버 연동 | 예정 |
