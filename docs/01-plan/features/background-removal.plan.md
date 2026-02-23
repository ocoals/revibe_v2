# Plan: Background Removal (배경 제거)

> ClosetIQ 아이템 이미지 배경 제거 기능

## 1. Overview

### 1.1 Problem Statement

현재 옷장에 저장되는 아이템 이미지는 원본 사진 그대로(침대, 거울, 화장실 배경 등) 저장됨.
패션 앱의 핵심 비주얼인 옷장 그리드/매칭 결과가 지저분하게 보여 앱 퀄리티 인식이 낮음.

### 1.2 Goal

아이템 등록 시 배경을 자동 제거하여 깔끔한 아이템 이미지를 제공한다.

### 1.3 Background

PRD, TDD, 사업기획서에 핵심 기능으로 명시되어 있었으나 MVP 인프라 단순화를 위해 deferred됨:
- PRD: "배경 제거 (rembg) → 아이템 분리 → 색상 추출"
- TDD 7.2: "remove.bg API (Primary) → HuggingFace RMBG-1.4 (Fallback)"
- F1 Gap Analysis D1: "배경 제거 → Claude Haiku AI 아이템 감지로 대체 (인프라 단순화)"

## 2. Scope

### 2.1 In Scope

| # | 항목 | 설명 |
|---|------|------|
| 1 | Supabase Edge Function | remove.bg API 호출 배경 제거 처리 |
| 2 | Fallback 전략 | remove.bg 실패 시 → 원본 이미지 폴백 |
| 3 | 온보딩 플로우 적용 (F1) | confirm_screen 아이템 저장 시 배경 제거 |
| 4 | 수동 추가 플로우 적용 (F3) | item_register_screen 저장 시 배경 제거 |
| 5 | 처리된 이미지 저장 | R2/Supabase Storage에 WebP 포맷 저장 |
| 6 | 기존 아이템 호환 | 기존 원본 이미지 아이템은 그대로 유지 |

### 2.2 Out of Scope

| # | 항목 | 이유 |
|---|------|------|
| 1 | On-device ML 배경 제거 | Phase 2에서 비용 데이터 기반 검토 |
| 2 | 기존 아이템 일괄 재처리 | 배포 후 별도 마이그레이션으로 진행 |
| 3 | 색상 추출 개선 (K-Means) | 현재 AI 기반 색상 감지가 충분히 동작 |
| 4 | per-item 크롭 (아이템별 분리) | 현재는 전체 사진 배경 제거만 |

## 3. Technical Approach

### 3.1 Architecture

```
[Flutter App]
  │
  │ 이미지 촬영/선택
  │ ImageUtils.processImage() (리사이즈 + JPEG)
  │
  ├─→ [Supabase Edge Function: remove-background]
  │     │
  │     ├─ Primary: remove.bg API
  │     │   POST https://api.remove.bg/v1.0/removebg
  │     │   → 배경 제거된 PNG 반환
  │     │
  │     ├─ Fallback: 원본 이미지 반환 (API 실패 시)
  │     │
  │     └─ 응답: { processed_image_base64, used_fallback }
  │
  ├─→ [Supabase Storage: wardrobe-images]
  │     └─ {user_id}/{item_id}_processed.png
  │
  └─→ [DB: wardrobe_items]
        └─ image_url = processed image URL
```

### 3.2 Edge Function: `remove-background`

```
POST /functions/v1/remove-background
Authorization: Bearer {supabase_token}
Content-Type: application/json

Request:
{
  "image_base64": "...",    // JPEG base64
}

Response:
{
  "image_base64": "...",    // 배경 제거된 PNG base64
  "used_fallback": false    // true이면 원본 그대로 반환됨
}
```

### 3.3 remove.bg API

- **Free Tier**: 월 50회 무료 (50 credits)
- **이미지 크기**: 최대 25MB, 결과 최대 4K
- **응답 시간**: 평균 2~3초
- **Secret**: `REMOVE_BG_API_KEY` (Supabase Secrets)

### 3.4 비용 분석

| 시나리오 | 월간 호출 | 비용 |
|----------|-----------|------|
| 초기 (유저 100명 이하) | ~200회 | 무료 (50회/유저 제한) |
| 성장기 (유저 1,000명) | ~3,000회 | ~$600 (초과 $0.20/건) |
| 최적화 후 (on-device) | 0 API 호출 | 0원 |

> 초기에는 유저당 월 등록 빈도가 낮으므로 무료 티어로 충분.
> 비용 증가 시 Phase 2 (on-device ML) 전환.

### 3.5 Fallback 전략

```
remove.bg API 호출
  ├─ 성공 (HTTP 200) → 배경 제거 이미지 반환
  ├─ 실패 (HTTP 4xx/5xx) → 원본 이미지 그대로 반환 + used_fallback: true
  └─ 타임아웃 (10초) → 원본 이미지 그대로 반환 + used_fallback: true
```

**핵심 원칙**: 배경 제거 실패가 아이템 등록 자체를 막아서는 안 됨.

## 4. Affected Features

| Feature | 영향 | 변경 사항 |
|---------|------|----------|
| F1 온보딩 | 높음 | confirm_screen 저장 시 배경 제거 API 호출 |
| F3 옷장 추가 | 높음 | item_registration_provider에서 배경 제거 후 업로드 |
| F3 옷장 그리드 | 중간 | 배경 제거된 이미지 표시 (기존 호환) |
| F2 룩 재현 결과 | 낮음 | matched_item_card에 깔끔한 이미지 자동 반영 |
| F5 데일리 기록 | 낮음 | 아이템 썸네일 자동 반영 |

## 5. Implementation Order

| # | 작업 | 파일 | 예상 |
|---|------|------|------|
| 1 | Edge Function 생성 | `supabase/functions/remove-background/index.ts` | 핵심 |
| 2 | Flutter 서비스 클래스 | `lib/core/services/background_removal_service.dart` | 핵심 |
| 3 | WardrobeRepository 수정 | `lib/features/wardrobe/data/wardrobe_repository.dart` | 핵심 |
| 4 | 온보딩 플로우 적용 | `lib/features/onboarding/presentation/confirm_screen.dart` | 핵심 |
| 5 | 수동 추가 플로우 적용 | `lib/features/wardrobe/providers/item_registration_provider.dart` | 핵심 |
| 6 | 처리 중 UI (로딩 상태) | confirm_screen, item_register_screen | UX |

## 6. UX Flow

### 6.1 온보딩 (F1)

```
기존: 사진 촬영 → AI 분석 → 확인 → [저장] → 원본 업로드
변경: 사진 촬영 → AI 분석 → 확인 → [저장] → 배경 제거 → 처리 이미지 업로드
                                              ↓ (실패 시)
                                          원본 이미지 업로드
```

### 6.2 수동 추가 (F3)

```
기존: 사진 촬영 → 속성 입력 → [등록] → 원본 업로드
변경: 사진 촬영 → 속성 입력 → [등록] → 배경 제거 → 처리 이미지 업로드
                                          ↓ (실패 시)
                                      원본 이미지 업로드
```

### 6.3 로딩 UX

- 기존 저장 로딩에 "배경 정리 중..." 단계 추가
- 평균 2~3초 추가 소요
- 실패해도 유저에게 에러 표시 안 함 (silent fallback)

## 7. Success Metrics

| 지표 | 목표 |
|------|------|
| 배경 제거 성공률 | >= 90% |
| 처리 시간 (P95) | < 5초 |
| 아이템 등록 전환율 변화 | 유지 또는 개선 |
| Fallback 발생률 | < 10% |

## 8. Risks & Mitigation

| 리스크 | 영향 | 대응 |
|--------|------|------|
| remove.bg 무료 한도 초과 | 월 50회 이후 비용 발생 | 유저당 일일 제한 + Phase 2 on-device 전환 |
| API 응답 지연 | UX 저하 | 10초 타임아웃 + 원본 폴백 |
| 배경 제거 품질 불량 | 옷 일부 잘림 | 원본도 함께 저장하여 유저 선택 가능 (v2) |
| Supabase Edge Function 콜드 스타트 | 첫 호출 느림 | 기존 Edge Function과 동일 패턴 |

## 9. Dependencies

| 의존성 | 현재 상태 | 필요 작업 |
|--------|----------|----------|
| remove.bg API Key | 미발급 | 가입 후 API Key 발급 |
| Supabase Secrets 설정 | - | `REMOVE_BG_API_KEY` 등록 |
| Supabase Edge Function 인프라 | 이미 있음 | 기존 패턴 재사용 |
| Supabase Storage (wardrobe-images) | 이미 있음 | PNG 업로드 지원 확인 |
