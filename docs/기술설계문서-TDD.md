# 기술 설계 문서 (Technical Design Document)

> **서비스:** AI 패션 옷장 관리 서비스 (ClosetIQ)
> **버전:** 1.1 (MVP)
> **작성일:** 2026-02-22
> **인터랙티브 버전:** technical-design-doc.jsx
>
> **관련 문서:**
> - [PRD](PRD.md) — 기능 요구사항, 프레임워크 선택 근거 (Section 5.6), 수익 모델
> - [UI/UX 설계문서](UI-UX-설계문서.md) — 화면 설계, 사용자 흐름, 디자인 시스템
> - [사업기획서](사업기획서.md) — 사업 개요, 경쟁 분석
> - [QA Strategy (G6)](G6-qa-testing-strategy.md) — 테스트 케이스, 접근성 테스트, CI/CD

---

## 1. 아키텍처 총괄

### 1.1 핵심 설계 결정

**자체 AI 서버 0대.** 모든 AI 추론은 Claude Haiku API 호출. 1인 개발자가 관리할 것은 "앱 + Edge Functions"뿐.

```
CLIENT (Flutter iOS/Android)
    │
    │ HTTPS (REST API)
    ▼
API LAYER (Supabase Edge Functions - Deno/TypeScript)
    │
    ├── Supabase PostgreSQL (DB + Auth + RLS)
    ├── Cloudflare R2 (이미지 저장 + CDN)
    └── Claude Haiku API (AI 추론, 룩 재현 전용)
```

### 1.2 기술 스택

| 계층 | 기술 | 선택 근거 |
|------|------|----------|
| 모바일 앱 | Flutter (Dart) | iOS/Android 동시 개발, 1인 개발자 최적 |
| API 서버 | Supabase Edge Functions (Deno/TS) | 서버 관리 불필요, 자동 스케일링 |
| 데이터베이스 | Supabase PostgreSQL | RLS 내장, Realtime 구독, Free → Pro |
| 이미지 저장 | Cloudflare R2 | S3 호환, egress 무료, 무료 10GB, CDN 내장 |
| AI 추론 | Claude Haiku API | 건당 ~$0.001, 프롬프트 변경만으로 분석 범위 조정 |
| 인증 | Supabase Auth | 카카오/Apple 소셜 로그인, JWT, RLS 연동 |
| 배경 제거 | remove.bg API (Free) → rembg fallback | 월 50회 무료(고품질), 초과 시 HF API |
| 푸시 알림 | Firebase Cloud Messaging | 무료, Flutter 네이티브 지원 |
| 날씨 | OpenWeather API | 무료 1,000 calls/day |
| 모니터링 | Sentry (Free tier) | 에러 추적, Flutter + Edge Function |

### 1.3 AI 사용 지점 (전체 서비스에서 단 1곳)

| 기능 | AI 사용 | 기술 |
|------|---------|------|
| 배경 제거 | ❌ | remove.bg API / rembg |
| 색상 추출 | ❌ | K-Means 클러스터링 (코드 로직) |
| 카테고리 선택 | ❌ | 사용자 탭 UI |
| **룩 재현 (레퍼런스 분석)** | **✅ Claude Haiku 1회** | **이미지 → 아이템 JSON** |
| 옷장 매칭 | ❌ | DB 쿼리 + 점수 계산 코드 |
| 코디 추천 | ❌ | 규칙 기반 (날씨 + 착용이력) |
| 갭 분석 딥링크 | ❌ | URL 문자열 생성 |

---

## 2. 인프라 설계

### 2.1 Edge Functions 구조

```
supabase/functions/
├── _shared/                    # 공유 유틸리티
│   ├── cors.ts                 # CORS 헤더
│   ├── auth.ts                 # JWT 검증 + 사용자 조회
│   ├── rate-limit.ts           # 요금제별 Rate Limit
│   ├── r2-client.ts            # Cloudflare R2 업로드/삭제
│   ├── claude-client.ts        # Claude Haiku API 래퍼
│   ├── color-utils.ts          # 색상 변환/거리 계산 (CIEDE2000)
│   ├── matching-engine.ts      # 매칭 점수 계산 핵심
│   └── types.ts                # 공유 타입 정의
├── wardrobe-upload/            # POST — 이미지 처리 + 아이템 생성
├── wardrobe-items/             # GET/PATCH/DELETE — CRUD
├── recreate-analyze/           # POST — AI분석 + 매칭 (핵심 API)
├── recreate-history/           # GET — 재현 히스토리
├── outfit-daily/               # POST/GET — 데일리 코디 (Tier 2)
├── outfit-recommend/           # GET — 코디 추천 (Tier 2)
├── billing-subscribe/          # POST — IAP 영수증 검증 (Tier 2)
└── billing-webhook/            # POST — 스토어 서버 알림 (Tier 2)
```

### 2.2 Cloudflare R2 이미지 저장 구조

| 경로 | 용도 | 접근 | 보존 |
|------|------|------|------|
| `/originals/{user_id}/{item_id}.jpg` | 원본 전신 사진 | Private (서명 URL) | 계정 삭제 시 |
| `/processed/{user_id}/{item_id}.webp` | 배경 제거된 아이템 | Public CDN | 계정 삭제 시 |
| `/references/{user_id}/{rec_id}.jpg` | 룩 재현 레퍼런스 | Private (서명 URL) | 6개월 |
| `/outfits/{user_id}/{date}.jpg` | 데일리 코디 전신 | Private (서명 URL) | 계정 삭제 시 |

**이미지 최적화:** 원본 JPEG max 2048px q85, 배경제거 WebP max 1024px q80, 아이템당 ~450KB

### 2.3 사용자 규모별 월 인프라 비용

| 구성요소 | 1,000명 | 5,000명 | 10,000명 |
|----------|---------|---------|----------|
| Supabase | Free (0원) | Pro (3.3만원) | Pro (3.3만원) |
| Cloudflare R2 | Free (0원) | ~2만원 | ~5만원 |
| Claude Haiku API | ~5,000원 | ~3.6만원 | ~7만원 |
| remove.bg | Free (0원) | ~1만원 | ~3만원 |
| **합계** | **~1.3만원** | **~11만원** | **~19만원** |

---

## 3. 데이터베이스 설계

### 3.1 ER 다이어그램 (핵심 관계)

```
profiles (1) ──── (N) wardrobe_items
    │                      │
    │                      │ (referenced in JSONB)
    │                      │
    ├──── (N) look_recreations
    │
    ├──── (N) daily_outfits ──── (N:M) outfit_items ──── wardrobe_items
    │
    ├──── (N) subscriptions
    │
    └──── (N) usage_counters (월별)
```

### 3.2 핵심 테이블 DDL

#### profiles (Supabase Auth 확장)

```sql
CREATE TABLE public.profiles (
  id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name    TEXT NOT NULL DEFAULT '',
  gender          TEXT CHECK (gender IN ('female','male','other','unset')) DEFAULT 'unset',
  birth_year      INTEGER,
  onboarding_completed BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

#### wardrobe_items (옷장 아이템)

```sql
CREATE TABLE public.wardrobe_items (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  image_url         TEXT NOT NULL,           -- 배경 제거된 WebP (R2 public CDN)
  original_image_url TEXT,                   -- 원본 JPEG (R2 key)
  category          TEXT NOT NULL CHECK (category IN (
    'tops','bottoms','outerwear','dresses','shoes','bags','accessories'
  )),
  subcategory       TEXT,                    -- 'knit','jeans','sneakers' 등
  color_hex         TEXT NOT NULL,           -- '#2C3E50'
  color_name        TEXT NOT NULL,           -- '네이비'
  color_hsl         JSONB NOT NULL,          -- {"h":210,"s":35,"l":24}
  style_tags        TEXT[] DEFAULT '{}',     -- {'casual','minimal'}
  fit               TEXT CHECK (fit IN ('oversized','regular','slim',NULL)),
  pattern           TEXT CHECK (pattern IN ('solid','stripe','check','floral','dot','print','other',NULL)),
  brand             TEXT,
  season            TEXT[] DEFAULT '{spring,summer,fall,winter}',
  wear_count        INTEGER NOT NULL DEFAULT 0,
  last_worn_at      TIMESTAMPTZ,
  is_active         BOOLEAN NOT NULL DEFAULT TRUE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_wardrobe_user ON wardrobe_items(user_id) WHERE is_active = TRUE;
CREATE INDEX idx_wardrobe_category ON wardrobe_items(user_id, category) WHERE is_active = TRUE;
```

#### look_recreations (룩 재현 결과)

```sql
CREATE TABLE public.look_recreations (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reference_image_url  TEXT NOT NULL,
  reference_analysis   JSONB NOT NULL,    -- Claude Haiku 응답 원본
  matched_items        JSONB NOT NULL DEFAULT '[]',
  gap_items            JSONB NOT NULL DEFAULT '[]',
  overall_score        INTEGER NOT NULL DEFAULT 0,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

#### usage_counters (요금제 제한 관리)

```sql
CREATE TABLE public.usage_counters (
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  month_key        TEXT NOT NULL,          -- '2026-02'
  wardrobe_count   INTEGER NOT NULL DEFAULT 0,
  recreation_count INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (user_id, month_key)
);
```

#### daily_outfits + outfit_items (Tier 2)

```sql
CREATE TABLE public.daily_outfits (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  outfit_date DATE NOT NULL,
  image_url   TEXT,
  notes       TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, outfit_date)
);

CREATE TABLE public.outfit_items (
  outfit_id UUID NOT NULL REFERENCES daily_outfits(id) ON DELETE CASCADE,
  item_id   UUID NOT NULL REFERENCES wardrobe_items(id) ON DELETE CASCADE,
  position  INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (outfit_id, item_id)
);
```

#### subscriptions (Tier 2)

```sql
CREATE TABLE public.subscriptions (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan           TEXT NOT NULL CHECK (plan IN ('monthly','yearly','early_bird')),
  status         TEXT NOT NULL CHECK (status IN ('active','expired','cancelled','pending')) DEFAULT 'pending',
  platform       TEXT NOT NULL CHECK (platform IN ('apple','google')),
  receipt_data   TEXT,
  transaction_id TEXT,
  started_at     TIMESTAMPTZ,
  expires_at     TIMESTAMPTZ,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 3.3 Row Level Security (모든 테이블)

```sql
-- 모든 테이블에 동일 패턴 적용
ALTER TABLE public.[테이블명] ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own data"
  ON public.[테이블명] FOR ALL USING (auth.uid() = user_id);
```

### 3.4 카테고리 enum 매핑

| DB (영문) | 한국어 | subcategory 예시 |
|-----------|--------|-----------------|
| tops | 상의 | tshirt, shirt, blouse, knit, sweatshirt, hoodie, vest |
| bottoms | 하의 | jeans, slacks, shorts, skirt, leggings |
| outerwear | 아우터 | jacket, coat, padding, cardigan, windbreaker |
| dresses | 원피스 | mini, midi, maxi, jumpsuit |
| shoes | 신발 | sneakers, boots, sandals, loafers, heels |
| bags | 가방 | backpack, shoulder, crossbody, tote, clutch |
| accessories | 액세서리 | hat, scarf, belt, jewelry, sunglasses |

---

## 4. API 명세서

### 4.0 공통 사항

- **Base URL:** `https://[PROJECT_REF].supabase.co/functions/v1`
- **인증:** `Authorization: Bearer <supabase_access_token>`
- **Content-Type:** `application/json` (이미지 업로드는 `multipart/form-data`)
- **에러 응답:** `{"error": "message", "code": "ERROR_CODE"}`

### 4.1 POST /wardrobe/upload — 아이템 등록

전신 사진 업로드 → 배경 제거 → 색상 추출 → 아이템 생성. **AI 호출 0회.**

**Request** (multipart/form-data):

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| image | File | ✅ | JPEG/PNG, max 10MB |
| category | string | ✅ | tops/bottoms/outerwear/dresses/shoes/bags/accessories |
| subcategory | string | | 세부 카테고리 |
| style_tags | string | | JSON array 문자열 `'["casual"]'` |
| fit | string | | oversized/regular/slim |
| pattern | string | | solid/stripe/check/floral/dot/print/other |
| brand | string | | 브랜드명 |
| season | string | | JSON array 문자열 `'["fall","winter"]'` |

**Response 201:**
```json
{
  "id": "uuid",
  "image_url": "https://images.closetiq.app/processed/...",
  "category": "tops",
  "color_hex": "#5B7DB1",
  "color_name": "스틸블루",
  "color_hsl": {"h": 214, "s": 32, "l": 53},
  "style_tags": ["casual"],
  "wear_count": 0,
  "created_at": "2026-02-21T09:00:00Z"
}
```

**에러:** 400 (이미지 누락), 403 (WARDROBE_LIMIT_REACHED), 413 (10MB 초과)

### 4.2 GET /wardrobe/items — 아이템 목록

**Query Parameters:**

| 파라미터 | 기본값 | 설명 |
|----------|--------|------|
| category | (전체) | 카테고리 필터 |
| sort | created_at | created_at / wear_count / last_worn_at |
| order | desc | desc / asc |
| limit | 20 | 1~50 |
| offset | 0 | 페이지네이션 |

**Response 200:** `{ "items": [...], "total": 28, "has_more": true }`

### 4.3 PATCH /wardrobe/items/:id — 아이템 수정

**Body:** 수정할 필드만 포함 (category, subcategory, style_tags, fit, pattern, brand, season)

### 4.4 DELETE /wardrobe/items/:id — 아이템 삭제

소프트 삭제 (is_active = false). R2 이미지는 30일 후 정리.

### 4.5 POST /recreate/analyze — 룩 재현 (핵심 API)

레퍼런스 이미지 → **Claude Haiku 1회 호출** → 매칭 엔진 → 결과 반환

**Request** (multipart/form-data):

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| reference_image | File | ✅ | JPEG/PNG, max 10MB |

**Response 200:**
```json
{
  "id": "rec-uuid",
  "overall_score": 78,
  "reference_analysis": {
    "items": [
      {
        "index": 0,
        "category": "tops",
        "subcategory": "knit",
        "color": {"hex": "#F5F0E8", "name": "크림", "hsl": {"h":40,"s":50,"l":93}},
        "style": ["casual", "minimal"],
        "fit": "oversized",
        "pattern": "solid"
      }
    ],
    "overall_style": "casual_minimal",
    "occasion": "daily"
  },
  "matched_items": [
    {
      "ref_index": 0,
      "wardrobe_item": { "id": "...", "image_url": "...", "color_name": "아이보리" },
      "score": 92,
      "breakdown": {"category": 40, "color": 29, "style": 18, "bonus": 5},
      "match_reasons": ["같은 니트 카테고리", "유사한 크림 톤"]
    }
  ],
  "gap_items": [
    {
      "ref_index": 2,
      "category": "shoes",
      "description": "브라운 캐주얼 로퍼",
      "search_keywords": "브라운 로퍼 캐주얼",
      "deeplinks": {
        "musinsa": "https://www.musinsa.com/search/musinsa/goods?q=브라운+로퍼",
        "ably": "https://m.a-bly.com/search?keyword=브라운+로퍼",
        "zigzag": "https://zigzag.kr/search?keyword=브라운+로퍼"
      }
    }
  ]
}
```

**에러:** 400, 403 (RECREATION_LIMIT_REACHED), 408 (AI_TIMEOUT), 422 (NO_FASHION_ITEMS), 502 (AI_ERROR)

### 4.6 GET /recreate/history — 재현 히스토리

**Query:** `?limit=10&offset=0`

### 4.7 POST /outfit/daily — 데일리 코디 기록 (Tier 2)

**Body:** `{ "outfit_date": "2026-02-21", "item_ids": ["uuid",...], "notes": "..." }`

### 4.8 GET /outfit/recommend — 코디 추천 (Tier 2)

날씨 + 착용이력 기반 규칙 추천. AI 호출 없음.

### 4.9 에러 코드 전체 목록

| 코드 | HTTP | 설명 | 클라이언트 대응 |
|------|------|------|----------------|
| AUTH_REQUIRED | 401 | 토큰 누락/만료 | 로그인 화면 |
| WARDROBE_LIMIT_REACHED | 403 | 무료 30벌 한도 | 프리미엄 업그레이드 |
| RECREATION_LIMIT_REACHED | 403 | 무료 월 5회 한도 | 프리미엄 업그레이드 |
| INVALID_IMAGE | 400 | 이미지 파싱 실패 | 재촬영 유도 |
| NO_FASHION_ITEMS | 422 | 패션 아이템 없음 | 다른 이미지 선택 |
| AI_TIMEOUT | 408 | Claude 10초 초과 | 재시도 버튼 |
| AI_ERROR | 502 | Claude API 오류 | 재시도 버튼 |
| RATE_LIMITED | 429 | 요청 과다 | 잠시 후 재시도 |

---

## 5. AI 파이프라인 (Claude Haiku)

### 5.1 호출 스펙

- **모델:** `claude-haiku-4-5-20251001`
- **max_tokens:** 1024
- **입력:** 이미지 (base64 JPEG) + 분석 프롬프트
- **출력:** JSON (아이템 목록 + 속성)
- **타임아웃:** 10초
- **재시도:** 최대 2회 (1초, 2초 대기)

### 5.2 프롬프트

```
이 사진에 보이는 패션 아이템을 분석해주세요.
반드시 아래 JSON 형식으로만 응답하세요. 다른 텍스트는 절대 포함하지 마세요.

{
  "items": [
    {
      "index": 0,
      "category": "tops|bottoms|outerwear|dresses|shoes|bags|accessories",
      "subcategory": "구체적 소분류",
      "color": {"hex": "#000000", "name": "한국어 색상명", "hsl": {"h":0,"s":0,"l":0}},
      "style": ["casual", "formal", ...],
      "fit": "oversized|regular|slim|null",
      "pattern": "solid|stripe|check|...|null",
      "material": "cotton|denim|...|null"
    }
  ],
  "overall_style": "전체 코디 스타일",
  "occasion": "daily|office|date|formal|sport|outdoor"
}

규칙:
- 명확히 보이는 패션 아이템만 포함
- 배경 소품, 인테리어 제외
- 색상은 가장 넓은 면적의 대표 색상
- HSL 값 정확 계산
```

### 5.3 응답 검증

1. JSON 파싱 검증
2. items 배열 존재 확인
3. 각 아이템 category가 허용 목록에 포함 확인
4. HSL 범위 검증 (h: 0~360, s: 0~100, l: 0~100), 범위 초과 시 hex에서 재계산
5. 검증 실패 시 재시도

### 5.4 API 에러 복구 전략

#### 5.4.1 재시도 & 최종 실패 처리

```
Claude Haiku API 호출
  → 실패 시 1초 후 1차 재시도
  → 실패 시 2초 후 2차 재시도
  → 최종 실패 시:
      1. look_recreations 레코드 status = 'failed'로 저장
      2. 사용자 화면: "분석에 실패했어요. 다시 시도해주세요" + [재시도] 버튼
      3. usage_counters 증가하지 않음 (실패 건은 한도에서 차감하지 않음)
      4. Sentry에 에러 리포트 전송
```

#### 5.4.2 부분 결과 처리

레퍼런스 이미지에서 5개 아이템 중 3개만 분석 성공한 경우:

| 상황 | 처리 방식 |
|------|----------|
| items 배열이 비어있음 (0개) | 422 NO_FASHION_ITEMS 에러 → "패션 아이템을 찾을 수 없어요" |
| items 1개 이상 존재 | 성공한 아이템만으로 매칭 진행, 결과 화면에 "일부 아이템만 분석됨" 배지 표시 |
| JSON 파싱 자체 실패 | 재시도 → 최종 실패 시 위 5.4.1 흐름 |

#### 5.4.3 미완료 트랜잭션 DB 상태 관리

```sql
-- look_recreations에 status 컬럼 추가
ALTER TABLE look_recreations ADD COLUMN status TEXT NOT NULL DEFAULT 'completed'
  CHECK (status IN ('pending', 'completed', 'failed'));

-- 처리 흐름
-- 1. API 호출 시작 → status = 'pending'으로 INSERT
-- 2. 성공 → status = 'completed', matched_items/gap_items 업데이트
-- 3. 실패 → status = 'failed'
-- 4. 30분 이상 'pending' 상태 → 배치로 'failed' 처리
```

#### 5.4.4 사용자 대면 에러 메시지 매핑

| 에러 코드 | 사용자 메시지 | 액션 |
|----------|-------------|------|
| AI_TIMEOUT | "분석 시간이 초과됐어요" | [다시 시도] |
| AI_ERROR | "일시적인 오류가 발생했어요" | [다시 시도] |
| NO_FASHION_ITEMS | "패션 아이템을 찾을 수 없어요. 사람이 옷을 입은 사진을 선택해주세요" | [다른 이미지 선택] |
| RATE_LIMITED | "요청이 너무 많아요. 잠시 후 다시 시도해주세요" | 30초 카운트다운 |
| WARDROBE_LIMIT_REACHED | "옷장이 가득 찼어요! 프리미엄으로 업그레이드하면 무제한이에요" | [프리미엄 보기] |
| RECREATION_LIMIT_REACHED | "이번 달 무료 룩 재현을 모두 사용했어요" | [프리미엄 보기] + 잔여 일수 |

### 5.4 비용 추정

| 시나리오 | 월 호출 | 월 비용 |
|----------|---------|---------|
| 1,000 MAU × 5회 | 5,000 | ~₩5,000 |
| 5,000 MAU × 5.6회 | 28,000 | ~₩36,000 |
| 10,000 MAU × 5.6회 | 56,000 | ~₩72,000 |

---

## 6. 매칭 엔진 설계

### 6.1 알고리즘 개요

AI 호출 없이 순수 코드 로직으로 동작. 각 레퍼런스 아이템에 대해 사용자 옷장에서 최적 매칭을 찾는다.

**점수 구성 (총 100점):**

| 요소 | 배점 | 산출 방식 |
|------|------|----------|
| 카테고리 일치 | 40 | 같은 카테고리 = 40, 불일치 = 0 (필터로 사전 처리) |
| 색상 유사도 | 30 | CIEDE2000 색차 → 0~30점 변환 |
| 스타일 일치 | 20 | 태그 겹침 비율 × 20 |
| 보너스 | 10 | 핏(3) + 패턴(3) + 소분류(4) 일치 보너스 |

**매칭 임계값:** 50점 이상 = 매칭 성공, 미만 = 갭 아이템

### 6.2 색상 유사도 계산

**알고리즘 확정: CIEDE2000** (Euclidean RGB 거리 대신 채택)

CIEDE2000을 선택한 이유:
- Euclidean RGB는 인간의 색상 인지와 불일치 (예: 같은 ΔE에서 녹색 영역은 덜 차이나 보이고, 파랑 영역은 더 차이나 보임)
- CIEDE2000은 CIE L*a*b* 색공간에서 인간 인지를 보정하여, 네이비/차콜 같은 어두운 색 구분과 크림/베이지 같은 밝은 색 구분에서 정확도가 높음
- 패션 도메인에서 "비슷한 색"이라는 사용자 감각과 가장 부합

| deltaE 범위 | 의미 | 점수 (0~30) |
|-------------|------|------------|
| < 5 | 거의 같은 색 | 28~30 |
| 5~15 | 유사한 색 | 20~28 |
| 15~30 | 같은 톤 | 10~20 |
| > 30 | 다른 색 | 0~10 |

### 6.3 매칭 프로세스

```
for each refItem in referenceAnalysis.items:
    1. 같은 카테고리로 필터 (tops↔tops)
    2. 이미 매칭된 아이템 제외 (동일 카테고리 중복 매칭 방지)
    3. 후보별 점수 계산 (color + style + bonus)
    4. 최고 점수 아이템 선택
    5. 점수 ≥ 50 → matched_items에 추가
       점수 < 50 → gap_items에 추가 + 딥링크 생성
```

### 6.4 엣지 케이스 처리

#### 레퍼런스 아이템 수 > 옷장 아이템 수

| 상황 | 처리 |
|------|------|
| 레퍼런스 10개 아이템, 옷장 3개 | 3개만 매칭 시도, 나머지 7개는 자동 gap_items |
| 옷장에 해당 카테고리 0개 | 해당 아이템 즉시 gap_items (매칭 시도 없이) |

#### 전체 갭 (모든 아이템 50점 미만)

```
결과 화면 표시:
  overall_score = 0 (또는 실제 최고 점수)
  "아직 매칭되는 아이템이 없어요 😊"
  "옷장에 아이템을 더 추가하면 매칭률이 올라가요!"
  → [옷장에 추가하기] CTA 표시
  → 모든 아이템을 gap_items로 표시 (딥링크 포함)
```

#### 동일 카테고리 중복 매칭 방지

```
// 한 번 매칭된 옷장 아이템은 다른 레퍼런스 아이템에 재사용 불가
// 예: 레퍼런스에 "상의 A", "상의 B"가 있고, 옷장에 "상의 1"만 있는 경우
//   → 상의 A ↔ 상의 1 매칭 (더 높은 점수)
//   → 상의 B → gap_items (매칭 가능한 옷장 아이템 없음)

const usedItemIds = new Set<string>();
for (const refItem of refItems) {
    const candidates = wardrobeItems
        .filter(w => w.category === refItem.category)
        .filter(w => !usedItemIds.has(w.id));
    // ... 점수 계산 후 최적 선택
    if (bestMatch && bestMatch.score >= 50) {
        usedItemIds.add(bestMatch.id);
    }
}
```

### 6.4 딥링크 생성 (갭 아이템)

```
무신사: https://www.musinsa.com/search/musinsa/goods?q={keywords}
에이블리: https://m.a-bly.com/search?keyword={keywords}
지그재그: https://zigzag.kr/search?keyword={keywords}

keywords = "{색상명} {subcategory}" (예: "브라운 로퍼")
```

Phase 2에서 CPA 파라미터 추가: `&ref=closetiq&utm_source=closetiq`

---

## 7. 이미지 처리 파이프라인

### 7.1 처리 흐름

```
앱에서 이미지 수신 (JPEG, max 10MB)
  → 1. EXIF 회전 보정 + 리사이즈 (max 2048px) + JPEG q85
  → 2. 배경 제거 (remove.bg API → HF API fallback)
  → 3. 색상 추출 (K-Means k=3, 투명 픽셀 제외)
  → 4. R2 저장 (원본 JPEG + 처리본 WebP)
```

### 7.2 배경 제거 전략

| 우선순위 | 방법 | 품질 | 비용 | 비고 |
|----------|------|------|------|------|
| Primary | remove.bg API | 높음 | 월 50회 무료 | 초과 시 $0.20/건 |
| Fallback | HuggingFace RMBG-1.4 | 중간 | 무료 (추론 API) | 속도 느릴 수 있음 |

### 7.3 색상 추출 (K-Means)

1. 배경 제거된 이미지에서 투명 픽셀 제외
2. RGB 공간에서 K-Means 클러스터링 (k=3, 20 iterations)
3. 가장 큰 클러스터의 centroid = 대표 색상
4. RGB → hex → HSL 변환
5. HSL → 한국어 색상명 매핑 (무채색 판별 포함)

### 7.4 한국어 색상명 매핑 규칙

#### 7.4.1 무채색 판별 (채도 < 10%)

| 색상명 | 명도(L) 범위 | HSL 예시 |
|--------|-------------|---------|
| 화이트 | 90~100% | (0, 0, 95) |
| 아이보리 | 85~95% (h=30~50, s=10~30) | (40, 20, 92) |
| 라이트그레이 | 70~90% | (0, 0, 80) |
| 그레이 | 40~70% | (0, 0, 55) |
| 차콜 | 15~40% | (0, 0, 28) |
| 블랙 | 0~15% | (0, 0, 8) |

> **무채색 판별 기준:** 채도(Saturation) < 10%이면 무채색으로 분류. 명도에 따라 위 6단계로 구분.

#### 7.4.2 유채색 매핑 테이블 (19개 색상명)

| 색상명 | Hue 범위 | 명도(L) 범위 | 채도(S) 최소 | HSL 예시 |
|--------|---------|-------------|-------------|---------|
| 레드 | 0~10, 350~360 | 30~60% | 50% | (0, 70, 45) |
| 와인 | 340~360, 0~10 | 15~35% | 30% | (350, 45, 25) |
| 코랄 | 0~20 | 60~80% | 40% | (10, 60, 70) |
| 오렌지 | 20~40 | 40~70% | 50% | (30, 80, 55) |
| 베이지 | 30~50 | 70~90% | 15~40% | (40, 30, 82) |
| 크림 | 30~50 | 88~98% | 20~60% | (40, 50, 93) |
| 옐로우 | 50~65 | 45~75% | 50% | (55, 80, 60) |
| 머스타드 | 40~55 | 35~55% | 40% | (48, 60, 45) |
| 라임/연두 | 65~90 | 40~70% | 40% | (80, 55, 55) |
| 그린 | 90~160 | 25~60% | 30% | (130, 50, 40) |
| 카키 | 60~100 | 25~45% | 15~40% | (80, 30, 35) |
| 민트 | 150~180 | 65~85% | 30% | (165, 45, 75) |
| 스카이블루 | 190~210 | 60~80% | 40% | (200, 55, 70) |
| 블루 | 210~240 | 35~60% | 40% | (220, 60, 50) |
| 네이비 | 210~250 | 10~35% | 25% | (220, 50, 25) |
| 라벤더 | 260~290 | 60~80% | 30% | (275, 40, 70) |
| 퍼플 | 260~300 | 20~55% | 30% | (280, 50, 40) |
| 핑크 | 310~350 | 60~85% | 30% | (330, 50, 72) |
| 브라운 | 15~40 | 15~40% | 30% | (25, 50, 30) |

#### 7.4.3 명도에 따른 변형 접두사

| 접두사 | 조건 | 예시 |
|--------|------|------|
| 라이트 | L > 70% (해당 색상 기본 범위 대비) | 라이트블루, 라이트핑크 |
| 다크 | L < 30% (해당 색상 기본 범위 대비) | 다크그린, 다크브라운 |
| (기본) | 표준 범위 내 | 블루, 핑크 |

#### 7.4.4 매핑 우선순위

```
1. 채도 < 10% → 무채색 판별 (화이트~블랙)
2. 채도 10~15% & 명도 > 70% → 베이지/아이보리 체크
3. Hue 범위 매칭 → 해당 색상명
4. 명도에 따라 접두사(라이트/다크) 추가
5. 매핑 실패 시 → 가장 가까운 hue 범위의 색상명 사용
```

### 7.5 이미지 처리 실패 모드 & 폴백

#### 7.5.1 K-Means 실패 시 폴백

| 실패 조건 | 원인 | 폴백 처리 |
|----------|------|----------|
| 투명 픽셀 > 95% | 배경 제거가 과도하게 적용됨 | 원본 이미지에서 K-Means 재시도 (배경 포함) |
| k=3 클러스터링 미수렴 (20 iterations 초과) | 매우 복잡한 패턴 (레인보우, 타이다이 등) | k=1로 재시도 → 단일 대표색 추출 |
| 모든 클러스터가 동일 색상 | 완전 단색 아이템 | 해당 단일 색상을 대표색으로 확정 |

#### 7.5.2 배경 제거 실패 처리

| 실패 조건 | 감지 방법 | 처리 |
|----------|----------|------|
| remove.bg API 에러 | HTTP 5xx 응답 | HuggingFace rembg API로 fallback |
| HuggingFace도 실패 | HTTP 에러 | "배경 제거 없이 등록할까요?" 다이얼로그 → 원본 이미지로 저장 |
| 완전 투명 출력 (투명 > 99%) | 출력 이미지 분석 | "배경 제거가 잘 되지 않았어요" 토스트 + 원본 이미지로 폴백 |

#### 7.5.3 의류 영역 크기 검증

```
배경 제거 후:
  불투명 픽셀 비율 = 불투명 픽셀 수 / 전체 픽셀 수

  비율 < 5%  → 배경 제거 실패로 판정 (7.5.2 참조)
  비율 < 20% → "옷이 너무 작게 나왔어요. 가까이에서 다시 찍어주세요" + [재촬영] 버튼
  비율 ≥ 20% → 정상 처리
```

#### 7.5.4 EXIF GPS 데이터 제거 확인

```
이미지 업로드 처리 순서:
  1. EXIF 메타데이터 파싱
  2. GPS 관련 태그 존재 여부 확인
     → GPSLatitude, GPSLongitude, GPSAltitude 등
  3. GPS 태그 존재 시 → 제거 후 저장
  4. GPS 태그 제거 확인 로그 기록
  5. 원본 이미지에도 GPS 제거 적용 후 R2 저장

주의: 클라이언트에서 1차 제거 + 서버에서 2차 확인 (이중 보호)
```

---

## 8. 인증 & 결제 시스템

### 8.1 인증 흐름

Supabase Auth OAuth → JWT 발급 → 모든 API에서 JWT 검증 → RLS로 데이터 격리

- 카카오 로그인: `supabase.auth.signInWithOAuth({ provider: 'kakao' })`
- Apple 로그인: `supabase.auth.signInWithOAuth({ provider: 'apple' })`
- 신규 가입 시 트리거로 profiles 자동 생성

### 8.2 요금제 제한 체크

| 기능 | 무료 | 프리미엄 |
|------|------|---------|
| 옷장 아이템 | 30벌 | 무제한 |
| 룩 재현 | 월 5회 | 무제한 |

확인 로직: subscriptions 테이블에서 active + 미만료 확인 → usage_counters에서 현재 사용량 비교

### 8.3 IAP 영수증 검증 (Tier 2)

- Apple: App Store Server API v2로 서버사이드 검증
- Google: Google Play Developer API로 서버사이드 검증
- 클라이언트 영수증 절대 신뢰하지 않음

### 8.4 구독 상태 전이 다이어그램

```
                    ┌─────────────┐
                    │   pending   │ ← 결제 시작
                    └──────┬──────┘
                           │ 영수증 검증 성공
                           ▼
                    ┌─────────────┐
     ┌──────────────│   active    │◄──── 재구독
     │              └──────┬──────┘
     │                     │
     │          ┌──────────┼──────────┐
     │          │          │          │
     │   결제 실패    만료 도래    사용자 해지
     │          │          │          │
     │          ▼          │          ▼
     │   ┌────────────┐   │   ┌────────────┐
     │   │grace_period│   │   │ cancelled  │
     │   │  (3일 유예) │   │   │(만료일까지  │
     │   └──────┬─────┘   │   │ 서비스 유지)│
     │     결제  │ 3일     │   └──────┬─────┘
     │     성공  │ 경과    │          │ 만료일 도래
     │          │         │          │
     │     ┌────┘    ┌────┘     ┌────┘
     │     │         │          │
     │     ▼         ▼          ▼
     │  active   ┌─────────────┐
     └──────────►│   expired   │
                 └─────────────┘
```

#### 8.4.1 구독 만료 시 기존 데이터 처리

| 항목 | 만료 시 처리 | 재구독 시 처리 |
|------|------------|--------------|
| 옷장 아이템 (30벌 초과분) | **숨김 처리** (is_active = false, is_hidden_by_plan = true) — 삭제하지 않음 | 즉시 복원 (is_active = true) |
| 룩 재현 히스토리 | 전체 조회 가능 (읽기 전용) | 변동 없음 |
| 월 5회 한도 | 적용 | 해제 (무제한) |
| 코디 캘린더 | 읽기만 가능 | 전체 기능 복원 |

```sql
-- wardrobe_items에 숨김 구분 컬럼 추가
ALTER TABLE wardrobe_items ADD COLUMN is_hidden_by_plan BOOLEAN NOT NULL DEFAULT FALSE;

-- 만료 시: 30벌 초과 아이템 숨김 (등록 순 오래된 것부터)
UPDATE wardrobe_items
SET is_active = FALSE, is_hidden_by_plan = TRUE
WHERE user_id = $1
  AND id NOT IN (
    SELECT id FROM wardrobe_items
    WHERE user_id = $1 AND is_active = TRUE AND is_hidden_by_plan = FALSE
    ORDER BY created_at DESC LIMIT 30
  );

-- 재구독 시: 숨김 아이템 복원
UPDATE wardrobe_items
SET is_active = TRUE, is_hidden_by_plan = FALSE
WHERE user_id = $1 AND is_hidden_by_plan = TRUE;
```

#### 8.4.2 usage_counters 월 갱신 로직

```
매월 1일 00:00 UTC:
  1. 새 month_key 레코드 자동 생성 (첫 API 호출 시 lazy init)
  2. 이전 달 카운터는 히스토리로 보존 (삭제하지 않음)
  3. recreation_count = 0으로 리셋
  4. wardrobe_count는 실제 active 아이템 수로 동기화

확인 시점:
  - 아이템 등록 시: wardrobe_count + 1, 한도 비교
  - 룩 재현 시: recreation_count + 1, 한도 비교 (성공 시에만 카운트)
```

#### 8.4.3 결제 실패 → 유예기간 → 만료 흐름

```
Day 0: 결제 실패 감지 (스토어 서버 알림 수신)
  → 구독 status = 'grace_period'
  → 사용자에게 "결제 수단을 확인해주세요" 앱 내 배너 표시
  → 푸시 알림 발송

Day 1: 재결제 시도 (스토어 자동)
  → 성공 시: status = 'active', 배너 제거
  → 실패 시: 배너 유지

Day 3: 유예기간 만료
  → 재결제 미성공 시: status = 'expired'
  → 프리미엄 기능 즉시 제한
  → 30벌 초과 아이템 숨김 처리
  → "프리미엄이 만료되었어요" 배너 표시
```

---

## 9. 보안 & 성능

### 9.1 보안 체크리스트

| 영역 | 대책 |
|------|------|
| 인증 | JWT 기반, 모든 Edge Function에서 검증 |
| 데이터 격리 | Row Level Security (자기 데이터만) |
| 이미지 접근 | 원본은 서명 URL (1시간 만료) |
| API 키 | Supabase Secrets에 저장 |
| 입력 검증 | Zod 스키마 + 파라미터 바인딩 |
| Rate Limit | IP당 60req/min + 요금제별 한도 |
| 개인정보 | EXIF GPS 데이터 제거 |
| 계정 삭제 | CASCADE + R2 이미지 cleanup |

### 9.2 성능 목표

| 지표 | 목표 | 최적화 |
|------|------|--------|
| 아이템 등록 | < 3초 | 배경 제거 API 병렬, 이미지 전처리 최소화 |
| 룩 재현 | < 5초 | Claude 스트리밍, 매칭 인메모리 |
| 옷장 목록 | < 500ms | 인덱스 + 페이지네이션 20개 |
| 이미지 로딩 | < 1초 | R2 CDN + WebP + 썸네일 |
| 앱 콜드 스타트 | < 2초 | Flutter AOT 컴파일 |

### 9.3 캐싱 전략

| 대상 | 위치 | TTL | 무효화 |
|------|------|-----|--------|
| 배경제거 이미지 | R2 CDN | 365일 | 아이템 삭제 시 |
| 옷장 목록 | 앱 로컬 SQLite | 5분 | 변경 시 push 무효화 |
| 구독 상태 | 앱 메모리 | 30분 | 구독 변경 시 |
| 날씨 데이터 | Edge Function 메모리 | 1시간 | 자동 만료 |

---

## 10. 배포 & 운영

### 10.1 환경 분리

| 환경 | Supabase | R2 | 용도 |
|------|----------|-----|------|
| Development | Local (Docker) | closetiq-dev | 로컬 개발 |
| Staging | Free (별도 프로젝트) | closetiq-staging | QA / 베타 |
| Production | Pro | closetiq-prod | 프로덕션 |

### 10.2 모니터링

| 도구 | 대상 | 알림 조건 |
|------|------|----------|
| Sentry | 앱 크래시, Edge Function 에러 | 새 에러 시 Slack |
| Supabase Dashboard | DB 성능, 연결 수 | 쿼리 > 1초 |
| Anthropic Console | API 사용량/비용 | 월 예산 80% |
| Custom | 가입자, MAU, 전환율 | 매일 Slack 리포트 |

### 10.3 DB 마이그레이션

```
supabase/migrations/
├── 20260221000001_create_profiles.sql
├── 20260221000002_create_wardrobe_items.sql
├── 20260221000003_create_look_recreations.sql
├── 20260221000004_create_usage_counters.sql
├── 20260301000001_create_daily_outfits.sql        # Tier 2
├── 20260301000002_create_subscriptions.sql        # Tier 2
```

### 10.4 배포 명령어

```bash
supabase db push                  # 마이그레이션 적용
supabase functions deploy --all   # Edge Functions 배포
flutter build ios --release       # iOS 빌드
flutter build appbundle           # Android 빌드
```

---

## 11. 오프라인 & 네트워크 복원

### 11.1 오프라인 동작 범위

| 기능 | 오프라인 동작 | 네트워크 필요 여부 |
|------|------------|-----------------|
| 옷장 아이템 조회 | ✅ SQLite 캐시에서 읽기 전용 조회 | 아니오 |
| 옷장 아이템 등록 | ❌ 이미지 업로드/배경 제거 불가 | **필수** |
| 룩 재현 | ❌ Claude Haiku API 호출 필수 | **필수** |
| 코디 추천 | ⚠️ 날씨 데이터 미갱신, 마지막 캐시 기준 | 권장 |
| 데일리 코디 기록 | ⚠️ 로컬 저장 후 복원 시 동기화 | 권장 |
| 구독 상태 확인 | ✅ 로컬 캐시 (30분 TTL) | 아니오 |

### 11.2 SQLite 로컬 캐시 전략

```
앱 로컬 SQLite 캐시 스키마:
  wardrobe_items_cache
    - 전체 컬럼 복제 (서버 DB와 동일 구조)
    - cached_at: 마지막 동기화 시각
    - sync_status: 'synced' | 'pending_upload' | 'pending_delete'

동기화 규칙:
  1. 앱 실행 시: 서버 DB → SQLite 전체 동기화 (최초 또는 5분 이상 경과 시)
  2. 아이템 변경 시: 서버 반영 성공 후 SQLite 업데이트
  3. 오프라인 변경 시: sync_status = 'pending_*'으로 저장, 복원 시 동기화
```

### 11.3 네트워크 상태 감지 & UI

```
네트워크 상태 감지 (connectivity_plus 패키지):
  - 연결됨: 정상 동작
  - 연결 끊김:
      1. 화면 상단에 오프라인 배너 표시: "오프라인 상태예요. 일부 기능이 제한됩니다"
      2. 네트워크 필요 기능에 disabled 상태 + 툴팁: "인터넷 연결이 필요해요"
      3. 배너 색상: Amber 500 (#F59E0B)
  - 복원 시:
      1. 오프라인 배너 제거
      2. 대기 중인 동기화 자동 실행
      3. "다시 연결되었어요!" 토스트 (2초 후 자동 사라짐)
```

### 11.4 네트워크 복원 시 자동 동기화

```
복원 시 동기화 순서 (우선순위):
  1. 구독 상태 갱신
  2. pending_upload 아이템 업로드 재시도
  3. pending_delete 아이템 삭제 반영
  4. 서버 → 로컬 전체 동기화 (다른 기기에서 변경된 내용 반영)
  5. 코디 기록 동기화

충돌 해결: 서버 타임스탬프 우선 (last-write-wins)
```

---

## 12. 복원력 & 상태 복구

### 12.1 이미지 업로드 중 앱 크래시

```
시나리오: 사용자가 아이템 등록 중 앱이 강제 종료됨

복구 전략:
  1. 이미지 선택 즉시 → 로컬 임시 디렉터리에 사본 저장
  2. 업로드 시작 시 → pending_uploads 테이블에 레코드 생성
       { image_path, category, created_at, status: 'uploading' }
  3. 업로드 성공 시 → pending_uploads 삭제 + 임시 파일 정리
  4. 앱 재실행 시:
     - pending_uploads에 레코드 존재 확인
     - 존재 시: "등록 중이던 아이템이 있어요. 이어서 등록할까요?" 다이얼로그
     - [이어서 등록] → 임시 이미지로 업로드 재시도
     - [삭제] → 임시 파일 + pending_uploads 레코드 정리
  5. 임시 파일 보존 기한: 7일 (초과 시 자동 정리)
```

### 12.2 AI 분석 중 네트워크 끊김

```
시나리오: 룩 재현 API 호출 중 네트워크가 끊김

복구 전략:
  1. API 호출 시작 → look_recreations에 status='pending' 레코드 생성
  2. 네트워크 끊김 감지 → 클라이언트에서 타임아웃 (15초)
  3. 사용자 화면: "네트워크가 끊겼어요. 다시 연결되면 재시도할게요"
  4. 네트워크 복원 시:
     - 자동 재시도 (동일 이미지로)
     - 재시도 성공 → 결과 표시
     - 재시도 실패 → "다시 시도해주세요" + [재시도] 버튼
  5. 서버 측: pending 상태 30분 경과 → 배치 작업으로 'failed' 처리
     - 사용량 카운터 증가하지 않음 (실패 건은 차감 안 함)
```

### 12.3 온보딩 중 이탈 & 복귀

```
시나리오: 온보딩 중간에 앱을 종료하고 나중에 다시 실행

복구 전략:
  1. 온보딩 각 단계 완료 시 → 로컬 저장소에 진행 상태 기록
       onboarding_progress: { step: 'photo_taken' | 'items_confirmed' | 'completed' }
  2. 다음 앱 실행 시 onboarding_completed = false이면:
     - step = 'photo_taken' → S04 아이템 확인 화면으로 이동 (사진 재활용)
     - step = 'items_confirmed' → 룩 재현 유도 화면으로 이동
     - step 없음 → S03 촬영 유도부터 시작
  3. "이어서 하기" vs "처음부터 다시" 선택지 제공

주의: 임시 촬영 이미지는 앱 로컬에 7일간 보존
```

---

## 부록: 변경 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|----------|
| 1.0 | 2026-02-22 | 초안 작성. 10개 섹션 완성. |
| 1.1 | 2026-02-22 | API 에러 복구 전략 (5.4), 매칭 엣지 케이스 (6.4), 색상명 전체 매핑 테이블 (7.4), 이미지 처리 실패 모드 (7.5), 구독 상태 전이 (8.4), 오프라인 명세 (Section 11), 복원력/상태 복구 (Section 12) 추가. |
