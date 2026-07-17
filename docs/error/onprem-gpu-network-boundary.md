# 온프레미스 GPU 서버 ↔ AWS VPC 네트워크 경계 관리

---

## 상황

laurel(온프레미스 GPU 서버)은 AWS VPC 외부에 위치해 있어, VPC 내부 리소스처럼 Security Group 참조만으로는 통신 경로를 구성할 수 없었다. 양방향으로 서로 다른 문제가 있었다.

**① AWS → laurel (Spring 백엔드/모니터링 서버가 laurel을 호출하는 방향)**

Spring 백엔드는 laurel의 Triton 추론 API(FastAPI, 8000)를, 모니터링 서버는 laurel의 Node/DCGM Exporter(9100, 9400)를 호출해야 했다. laurel은 사내 공유 GPU 서버라 자체 방화벽 정책이 있었고, 인바운드는 사내 리버스 프록시를 통해 **출발지 IP + 포트 단위로 화이트리스트가 걸려 있는 구조**였다. 임의로 포트를 열 수 없고, 매번 네트워크 담당자에게 정식으로 개방 요청을 넣어야 했다.

**② laurel → AWS (laurel의 로그를 AWS 쪽으로 push하는 방향)**

laurel의 Promtail이 모니터링 EC2의 Loki(3100)로 로그를 push하도록 구성했으나, `context deadline exceeded` 에러가 반복 발생했다. 원인을 추적한 결과, 기존 `monitoring_loki` Security Group 규칙이 `source_security_group_id`(SG 참조) 방식으로만 구성되어 있었다. SG 참조는 AWS 리소스 간에만 유효하기 때문에, VPC 외부에 있는 laurel의 트래픽은 SG 규칙 평가 단계에서 애초에 매칭되지 않고 차단되고 있었다.

---

## 판단 및 근거

**1. laurel → AWS 방향: SG 참조 대신 CIDR 기반 규칙 도입**

온프레미스 리소스는 AWS SG를 가질 수 없으므로 SG 참조 방식 자체가 성립하지 않는다고 판단, `source_security_group_id` 대신 `cidr_blocks`로 laurel의 고정 IP를 직접 허용하는 규칙으로 전환했다. 다만 GPU 서버 연동이 없는 환경(로컬 테스트 등)에서도 항상 이 리소스가 생성되면 불필요한 노출이 되므로, `gpu_server_cidrs` 변수가 비어 있으면 규칙 자체가 생성되지 않도록 `count` 조건을 걸어 모듈화했다.

```hcl
resource "aws_security_group_rule" "monitoring_loki_from_gpu" {
  count             = length(var.gpu_server_cidrs) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 3100
  to_port           = 3100
  protocol          = "tcp"
  cidr_blocks       = var.gpu_server_cidrs
  security_group_id = aws_security_group.monitoring.id
}
```

**2. AWS → laurel 방향: 상시 터널 대신 포트 화이트리스트 요청을 우선 채택**

laurel에 접근하는 방식으로 두 가지를 검토했다.

| 방식 | 장점 | 단점 |
| --- | --- | --- |
| SSH 리버스 터널(autossh) | 방화벽 정책 변경 없이 접근 가능 | 터널 프로세스를 상시 띄워둬야 하고, 끊김 시 재연결 로직·모니터링이 추가로 필요해 운영 부담 증가 |
| 포트 화이트리스트 정식 요청 | 별도 프로세스 관리 불필요, 장애 지점이 줄어듦 | 네트워크 담당자 승인 필요, 포트 추가 시마다 재요청 |

운영 복잡도가 낮은 **포트 화이트리스트 요청을 1순위**로 채택하고, 터널 방식은 승인이 막힐 경우의 폴백으로만 남겨뒀다.

**3. 필요한 트래픽만 용도별로 분리해 최소권한으로 요청**

한 번에 넓은 범위를 요청하지 않고, 트래픽 목적별로 포트와 출발지 IP를 분리해서 요청했다.

| 포트 | 용도 | 허용 출발지 |
| --- | --- | --- |
| 8000 | FastAPI(Triton) 번역 추론 API | AWS NAT Gateway IP |
| 9100 | 서버 모니터링(Node Exporter) | AWS 모니터링 서버 IP |
| 9400 | GPU 모니터링(DCGM Exporter) | AWS 모니터링 서버 IP |

API 트래픽과 모니터링 트래픽을 같은 출발지로 묶지 않고 분리한 이유는, 모니터링 서버가 뚫리는 것과 실제 서비스 트래픽 경로가 뚫리는 것의 파급 범위를 분리하기 위함이었다. 이 요청은 laurel의 리버스 프록시에 출발지 IP:포트 단위로 매핑되는 방식으로 반영됐다.

**4. 화이트리스트 정책이 이후 설계에 준 제약**

같은 프록시 정책 때문에 승인되지 않은 포트(gRPC 스트리밍용 등)는 추가로 열 수 없었다. 이 제약을 무리하게 풀려고 하지 않고, **이미 승인된 8000(HTTP) 포트만으로 동작 가능한 방식으로 API 설계 자체를 맞추는 쪽을 선택**했다. laurel이 공유 인프라라 네트워크 정책 변경 요청 자체의 리드타임과 승인 불확실성이 크다고 판단했기 때문이다.

---

## 결과

- **laurel → AWS**: Loki 로그 수집 정상화. `gpu_server_cidrs` 변수 하나만 바꾸면 laurel의 IP가 변경되거나 GPU 서버가 추가돼도 대응 가능한 구조로 정리
- **AWS → laurel**: 트래픽 목적(추론 API / 서버 모니터링 / GPU 모니터링)별로 포트와 출발지 IP가 분리된 최소권한 접근 통제 확립
- 두 방향 모두 "필요한 트래픽만, 필요한 출발지에서만" 원칙으로 정리되어, 이후 laurel의 IP 변경이나 신규 모니터링 포트 추가 시에도 동일한 패턴(변수 수정 + 화이트리스트 재요청)으로 대응 가능

**최종 트래픽 흐름 요약**

| 방향 | 트래픽 | 포트 | 허용 출발지 | 구성 방식 |
| --- | --- | --- | --- | --- |
| AWS → laurel | 번역 추론 API 호출 | 8000 | NAT Gateway IP | laurel 리버스 프록시 화이트리스트 |
| AWS → laurel | 서버 메트릭 스크래핑 | 9100 | 모니터링 서버 IP | laurel 리버스 프록시 화이트리스트 |
| AWS → laurel | GPU 메트릭 스크래핑 | 9400 | 모니터링 서버 IP | laurel 리버스 프록시 화이트리스트 |
| laurel → AWS | 로그 push (Promtail → Loki) | 3100 | laurel CIDR (`gpu_server_cidrs`) | Terraform Security Group Rule |

---

## 관련 문서

- [v2.8.0](../v2.8.0.md) — 외부 GPU 서버 → Loki 로그 수집 허용
- [README 핵심 설계 사항 — 온프레미스-AWS 하이브리드 네트워크 연동](../../README.md)
