# Design: F2 - Look Recreation (룩 재현)

> **Feature:** f2-look-recreation
> **Phase:** Design
> **Created:** 2026-02-23
> **Status:** Draft
> **Plan Reference:** [f2-look-recreation.plan.md](../../01-plan/features/f2-look-recreation.plan.md)
> **Related Docs:** [PRD F2](../../PRD.md), [TDD Sections 4~7](../../기술설계문서-TDD.md), [UI/UX Section 3.2](../../UI-UX-설계문서.md)

---

## 1. Data Models (Client - Dart)

All models follow the existing `WardrobeItem` pattern: `@freezed` + `@JsonKey(name:)` for snake_case DB mapping.

### 1.1 LookRecreation

```dart
// lib/features/recreation/data/models/look_recreation.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'reference_analysis.dart';
import 'matched_item.dart';
import 'gap_item.dart';

part 'look_recreation.freezed.dart';
part 'look_recreation.g.dart';

@freezed
class LookRecreation with _$LookRecreation {
  const factory LookRecreation({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'reference_image_url') required String referenceImageUrl,
    @JsonKey(name: 'reference_analysis') required ReferenceAnalysis referenceAnalysis,
    @JsonKey(name: 'matched_items') @Default([]) List<MatchedItem> matchedItems,
    @JsonKey(name: 'gap_items') @Default([]) List<GapItem> gapItems,
    @JsonKey(name: 'overall_score') @Default(0) int overallScore,
    @Default('completed') String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _LookRecreation;

  factory LookRecreation.fromJson(Map<String, dynamic> json) =>
      _$LookRecreationFromJson(json);
}
```

### 1.2 ReferenceAnalysis

```dart
// lib/features/recreation/data/models/reference_analysis.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reference_analysis.freezed.dart';
part 'reference_analysis.g.dart';

@freezed
class ReferenceAnalysis with _$ReferenceAnalysis {
  const factory ReferenceAnalysis({
    required List<ReferenceItem> items,
    @JsonKey(name: 'overall_style') required String overallStyle,
    required String occasion,
  }) = _ReferenceAnalysis;

  factory ReferenceAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ReferenceAnalysisFromJson(json);
}

@freezed
class ReferenceItem with _$ReferenceItem {
  const factory ReferenceItem({
    required int index,
    required String category,
    String? subcategory,
    required ReferenceColor color,
    @Default([]) List<String> style,
    String? fit,
    String? pattern,
    String? material,
  }) = _ReferenceItem;

  factory ReferenceItem.fromJson(Map<String, dynamic> json) =>
      _$ReferenceItemFromJson(json);
}

@freezed
class ReferenceColor with _$ReferenceColor {
  const factory ReferenceColor({
    required String hex,
    required String name,
    required Map<String, int> hsl,
  }) = _ReferenceColor;

  factory ReferenceColor.fromJson(Map<String, dynamic> json) =>
      _$ReferenceColorFromJson(json);
}
```

### 1.3 MatchedItem

```dart
// lib/features/recreation/data/models/matched_item.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../wardrobe/data/models/wardrobe_item.dart';

part 'matched_item.freezed.dart';
part 'matched_item.g.dart';

@freezed
class MatchedItem with _$MatchedItem {
  const factory MatchedItem({
    @JsonKey(name: 'ref_index') required int refIndex,
    @JsonKey(name: 'wardrobe_item') required WardrobeItem wardrobeItem,
    required int score,
    required ScoreBreakdown breakdown,
    @JsonKey(name: 'match_reasons') @Default([]) List<String> matchReasons,
  }) = _MatchedItem;

  factory MatchedItem.fromJson(Map<String, dynamic> json) =>
      _$MatchedItemFromJson(json);
}

@freezed
class ScoreBreakdown with _$ScoreBreakdown {
  const factory ScoreBreakdown({
    required int category,
    required int color,
    required int style,
    required int bonus,
  }) = _ScoreBreakdown;

  factory ScoreBreakdown.fromJson(Map<String, dynamic> json) =>
      _$ScoreBreakdownFromJson(json);
}
```

### 1.4 GapItem

```dart
// lib/features/recreation/data/models/gap_item.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'gap_item.freezed.dart';
part 'gap_item.g.dart';

@freezed
class GapItem with _$GapItem {
  const factory GapItem({
    @JsonKey(name: 'ref_index') required int refIndex,
    required String category,
    required String description,
    @JsonKey(name: 'search_keywords') required String searchKeywords,
    required Map<String, String> deeplinks,
  }) = _GapItem;

  factory GapItem.fromJson(Map<String, dynamic> json) =>
      _$GapItemFromJson(json);
}
```

---

## 2. Repository (Client)

```dart
// lib/features/recreation/data/recreation_repository.dart
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import 'models/look_recreation.dart';

class RecreationRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  static const _table = 'look_recreations';
  static const _usageTable = 'usage_counters';
  static const _bucket = 'reference-images';

  /// Upload reference image to storage, returns public URL
  Future<String> uploadReferenceImage(
    String userId,
    Uint8List imageBytes,
    String fileName,
  ) async {
    final path = '$userId/$fileName';
    await _client.storage.from(_bucket).uploadBinary(
          path,
          imageBytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );
    return _client.storage.from(_bucket).getPublicUrl(path);
  }

  /// Call recreate-analyze Edge Function
  /// Sends reference image as base64, returns LookRecreation result
  Future<LookRecreation> analyze(Uint8List imageBytes) async {
    final response = await _client.functions.invoke(
      'recreate-analyze',
      body: {
        'image_base64': _encodeBase64(imageBytes),
      },
    );

    if (response.status != 200) {
      final error = response.data as Map<String, dynamic>?;
      throw RecreationException(
        code: error?['code'] as String? ?? 'UNKNOWN_ERROR',
        message: error?['error'] as String? ?? 'Unknown error',
        statusCode: response.status,
      );
    }

    return LookRecreation.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetch recreation history (paginated)
  Future<List<LookRecreation>> fetchHistory({
    int limit = 10,
    int offset = 0,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .eq('status', 'completed')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return data.map((json) => LookRecreation.fromJson(json)).toList();
  }

  /// Fetch single recreation by ID
  Future<LookRecreation> fetchById(String id) async {
    final data = await _client.from(_table).select().eq('id', id).single();
    return LookRecreation.fromJson(data);
  }

  /// Get current month recreation count
  Future<int> getMonthlyUsage() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    final monthKey = _currentMonthKey();
    final result = await _client
        .from(_usageTable)
        .select('recreation_count')
        .eq('user_id', userId)
        .eq('month_key', monthKey)
        .maybeSingle();

    return (result?['recreation_count'] as int?) ?? 0;
  }

  String _currentMonthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  String _encodeBase64(Uint8List bytes) {
    return Uri.dataFromBytes(bytes, mimeType: 'image/jpeg')
        .data!
        .contentAsString();
    // Alternative: use dart:convert base64Encode
  }
}

/// Custom exception for recreation errors
class RecreationException implements Exception {
  final String code;
  final String message;
  final int statusCode;

  const RecreationException({
    required this.code,
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'RecreationException($code): $message';
}
```

**Storage bucket note:** A new Supabase Storage bucket `reference-images` needs to be created (migration or dashboard). Access: private (signed URLs), 6-month retention.

---

## 3. Edge Function: recreate-analyze

### 3.1 Main Handler

```typescript
// supabase/functions/recreate-analyze/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { analyzeReference } from "../_shared/claude-client.ts";
import { matchItems } from "../_shared/matching-engine.ts";
import { generateDeeplinks } from "../_shared/deeplink-generator.ts";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const FREE_RECREATION_LIMIT = 5;

serve(async (req: Request) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  try {
    // 1. Auth - extract JWT from Authorization header
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return errorResponse(401, "AUTH_REQUIRED", "Authorization required");
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return errorResponse(401, "AUTH_REQUIRED", "Invalid token");
    }

    // 2. Parse request body
    const body = await req.json();
    const imageBase64: string = body.image_base64;
    if (!imageBase64) {
      return errorResponse(400, "INVALID_IMAGE", "image_base64 is required");
    }

    // 3. Check usage limit
    const monthKey = getCurrentMonthKey();
    const usage = await getOrCreateUsage(supabase, user.id, monthKey);
    if (usage.recreation_count >= FREE_RECREATION_LIMIT) {
      // TODO: Check premium subscription status
      return errorResponse(403, "RECREATION_LIMIT_REACHED",
        "Monthly free recreation limit reached");
    }

    // 4. Create pending record
    const { data: pendingRecord } = await supabase
      .from("look_recreations")
      .insert({
        user_id: user.id,
        reference_image_url: "",  // Updated after storage upload
        reference_analysis: {},
        status: "pending",
      })
      .select()
      .single();

    // 5. Upload reference image to storage
    const imageBuffer = base64ToUint8Array(imageBase64);
    const imagePath = `${user.id}/${pendingRecord.id}.jpg`;
    await supabase.storage
      .from("reference-images")
      .upload(imagePath, imageBuffer, { contentType: "image/jpeg", upsert: true });
    const referenceImageUrl = supabase.storage
      .from("reference-images")
      .getPublicUrl(imagePath).data.publicUrl;

    // 6. Call Claude Haiku API
    const referenceAnalysis = await analyzeReference(imageBase64);

    // 7. Validate analysis
    if (!referenceAnalysis.items || referenceAnalysis.items.length === 0) {
      await updateRecordFailed(supabase, pendingRecord.id);
      return errorResponse(422, "NO_FASHION_ITEMS",
        "No fashion items detected in image");
    }

    // 8. Fetch user's wardrobe items
    const { data: wardrobeItems } = await supabase
      .from("wardrobe_items")
      .select("*")
      .eq("user_id", user.id)
      .eq("is_active", true);

    // 9. Run matching engine
    const { matchedItems, gapItems, overallScore } = matchItems(
      referenceAnalysis.items,
      wardrobeItems || []
    );

    // 10. Generate deeplinks for gap items
    const gapItemsWithLinks = gapItems.map((item) => ({
      ...item,
      deeplinks: generateDeeplinks(item.search_keywords),
    }));

    // 11. Update record to completed
    const { data: result } = await supabase
      .from("look_recreations")
      .update({
        reference_image_url: referenceImageUrl,
        reference_analysis: referenceAnalysis,
        matched_items: matchedItems,
        gap_items: gapItemsWithLinks,
        overall_score: overallScore,
        status: "completed",
      })
      .eq("id", pendingRecord.id)
      .select()
      .single();

    // 12. Increment usage counter
    await supabase
      .from("usage_counters")
      .update({ recreation_count: usage.recreation_count + 1 })
      .eq("user_id", user.id)
      .eq("month_key", monthKey);

    // 13. Return result
    return new Response(JSON.stringify(result), {
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      status: 200,
    });

  } catch (err) {
    console.error("recreate-analyze error:", err);
    return errorResponse(500, "INTERNAL_ERROR", "Internal server error");
  }
});

// --- Helper functions ---

function errorResponse(status: number, code: string, message: string) {
  return new Response(
    JSON.stringify({ error: message, code }),
    { headers: { ...CORS_HEADERS, "Content-Type": "application/json" }, status }
  );
}

function getCurrentMonthKey(): string {
  const now = new Date();
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}`;
}

async function getOrCreateUsage(supabase: any, userId: string, monthKey: string) {
  const { data } = await supabase
    .from("usage_counters")
    .select("*")
    .eq("user_id", userId)
    .eq("month_key", monthKey)
    .maybeSingle();

  if (data) return data;

  // Lazy init: create new month record
  const { data: newRecord } = await supabase
    .from("usage_counters")
    .insert({ user_id: userId, month_key: monthKey })
    .select()
    .single();
  return newRecord;
}

async function updateRecordFailed(supabase: any, recordId: string) {
  await supabase
    .from("look_recreations")
    .update({ status: "failed" })
    .eq("id", recordId);
}

function base64ToUint8Array(base64: string): Uint8Array {
  const binaryString = atob(base64);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes;
}
```

### 3.2 Claude Client

```typescript
// supabase/functions/_shared/claude-client.ts

const CLAUDE_API_URL = "https://api.anthropic.com/v1/messages";
const MODEL = "claude-haiku-4-5-20251001";
const MAX_TOKENS = 1024;
const TIMEOUT_MS = 10_000;
const MAX_RETRIES = 2;

const ANALYSIS_PROMPT = `이 사진에 보이는 패션 아이템을 분석해주세요.
반드시 아래 JSON 형식으로만 응답하세요. 다른 텍스트는 절대 포함하지 마세요.

{
  "items": [
    {
      "index": 0,
      "category": "tops|bottoms|outerwear|dresses|shoes|bags|accessories",
      "subcategory": "구체적 소분류",
      "color": {"hex": "#000000", "name": "한국어 색상명", "hsl": {"h":0,"s":0,"l":0}},
      "style": ["casual", "formal", "street", "minimal", "vintage"],
      "fit": "oversized|regular|slim|null",
      "pattern": "solid|stripe|check|floral|dot|print|other|null",
      "material": "cotton|denim|wool|leather|synthetic|null"
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
- category는 반드시 tops|bottoms|outerwear|dresses|shoes|bags|accessories 중 하나`;

const VALID_CATEGORIES = [
  "tops", "bottoms", "outerwear", "dresses", "shoes", "bags", "accessories"
];

export interface ReferenceAnalysisResult {
  items: ReferenceItemResult[];
  overall_style: string;
  occasion: string;
}

interface ReferenceItemResult {
  index: number;
  category: string;
  subcategory?: string;
  color: { hex: string; name: string; hsl: { h: number; s: number; l: number } };
  style: string[];
  fit?: string;
  pattern?: string;
  material?: string;
}

export async function analyzeReference(imageBase64: string): Promise<ReferenceAnalysisResult> {
  const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
  if (!apiKey) throw new Error("ANTHROPIC_API_KEY not set");

  let lastError: Error | null = null;

  for (let attempt = 0; attempt <= MAX_RETRIES; attempt++) {
    if (attempt > 0) {
      // Exponential backoff: 1s, 2s
      await new Promise((r) => setTimeout(r, attempt * 1000));
    }

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), TIMEOUT_MS);

      const response = await fetch(CLAUDE_API_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "anthropic-version": "2023-06-01",
        },
        body: JSON.stringify({
          model: MODEL,
          max_tokens: MAX_TOKENS,
          messages: [
            {
              role: "user",
              content: [
                {
                  type: "image",
                  source: { type: "base64", media_type: "image/jpeg", data: imageBase64 },
                },
                { type: "text", text: ANALYSIS_PROMPT },
              ],
            },
          ],
        }),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        throw new Error(`Claude API error: ${response.status}`);
      }

      const result = await response.json();
      const text = result.content[0]?.text || "";

      // Parse and validate JSON
      const analysis = parseAndValidate(text);
      return analysis;

    } catch (err) {
      lastError = err as Error;
      if (err instanceof Error && err.name === "AbortError") {
        lastError = new Error("AI_TIMEOUT: Claude API timed out");
      }
    }
  }

  throw lastError || new Error("AI_ERROR: All retries failed");
}

function parseAndValidate(text: string): ReferenceAnalysisResult {
  // Extract JSON from response (handle markdown code blocks)
  let jsonStr = text.trim();
  if (jsonStr.startsWith("```")) {
    jsonStr = jsonStr.replace(/^```(?:json)?\n?/, "").replace(/\n?```$/, "");
  }

  const parsed = JSON.parse(jsonStr);

  // Validate items array exists
  if (!Array.isArray(parsed.items)) {
    throw new Error("Invalid response: items array missing");
  }

  // Validate and sanitize each item
  parsed.items = parsed.items
    .filter((item: any) => VALID_CATEGORIES.includes(item.category))
    .map((item: any, i: number) => {
      // Validate HSL ranges
      if (item.color?.hsl) {
        item.color.hsl.h = clamp(item.color.hsl.h, 0, 360);
        item.color.hsl.s = clamp(item.color.hsl.s, 0, 100);
        item.color.hsl.l = clamp(item.color.hsl.l, 0, 100);
      }
      return { ...item, index: i };
    });

  return parsed as ReferenceAnalysisResult;
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}
```

### 3.3 Matching Engine

```typescript
// supabase/functions/_shared/matching-engine.ts
import { ciede2000 } from "./color-utils.ts";

const MATCH_THRESHOLD = 50;

// Score weights
const CATEGORY_SCORE = 40;
const COLOR_MAX_SCORE = 30;
const STYLE_MAX_SCORE = 20;
const BONUS_MAX_SCORE = 10;  // fit(3) + pattern(3) + subcategory(4)

interface RefItem {
  index: number;
  category: string;
  subcategory?: string;
  color: { hex: string; hsl: { h: number; s: number; l: number } };
  style: string[];
  fit?: string;
  pattern?: string;
}

interface WardrobeItem {
  id: string;
  category: string;
  subcategory?: string;
  color_hex: string;
  color_hsl: { h: number; s: number; l: number };
  style_tags: string[];
  fit?: string;
  pattern?: string;
  image_url: string;
  color_name: string;
  // ... other fields passed through
  [key: string]: any;
}

interface MatchResult {
  ref_index: number;
  wardrobe_item: WardrobeItem;
  score: number;
  breakdown: { category: number; color: number; style: number; bonus: number };
  match_reasons: string[];
}

interface GapResult {
  ref_index: number;
  category: string;
  description: string;
  search_keywords: string;
}

export function matchItems(
  refItems: RefItem[],
  wardrobeItems: WardrobeItem[]
): { matchedItems: MatchResult[]; gapItems: GapResult[]; overallScore: number } {
  const matchedItems: MatchResult[] = [];
  const gapItems: GapResult[] = [];
  const usedItemIds = new Set<string>();

  for (const refItem of refItems) {
    // 1. Filter by same category, exclude already matched
    const candidates = wardrobeItems.filter(
      (w) => w.category === refItem.category && !usedItemIds.has(w.id)
    );

    // No candidates → immediate gap
    if (candidates.length === 0) {
      gapItems.push(buildGapItem(refItem));
      continue;
    }

    // 2. Score each candidate
    let bestMatch: { item: WardrobeItem; score: number; breakdown: any; reasons: string[] } | null = null;

    for (const candidate of candidates) {
      const { score, breakdown, reasons } = scoreCandidate(refItem, candidate);
      if (!bestMatch || score > bestMatch.score) {
        bestMatch = { item: candidate, score, breakdown, reasons };
      }
    }

    // 3. Apply threshold
    if (bestMatch && bestMatch.score >= MATCH_THRESHOLD) {
      usedItemIds.add(bestMatch.item.id);
      matchedItems.push({
        ref_index: refItem.index,
        wardrobe_item: bestMatch.item,
        score: bestMatch.score,
        breakdown: bestMatch.breakdown,
        match_reasons: bestMatch.reasons,
      });
    } else {
      gapItems.push(buildGapItem(refItem));
    }
  }

  // Overall score: average of matched scores, 0 if none
  const overallScore = matchedItems.length > 0
    ? Math.round(matchedItems.reduce((sum, m) => sum + m.score, 0) / refItems.length)
    : 0;

  return { matchedItems, gapItems, overallScore };
}

function scoreCandidate(
  ref: RefItem,
  candidate: WardrobeItem
): { score: number; breakdown: { category: number; color: number; style: number; bonus: number }; reasons: string[] } {
  const reasons: string[] = [];

  // Category: always 40 (pre-filtered)
  const categoryScore = CATEGORY_SCORE;
  reasons.push(`같은 ${categoryToKorean(ref.category)} 카테고리`);

  // Color: CIEDE2000
  const deltaE = ciede2000(ref.color.hsl, candidate.color_hsl);
  const colorScore = deltaEToScore(deltaE);
  if (colorScore >= 20) {
    reasons.push(`유사한 ${candidate.color_name} 톤`);
  }

  // Style tags overlap
  const refStyles = ref.style || [];
  const candidateStyles = candidate.style_tags || [];
  const overlap = refStyles.filter((s) => candidateStyles.includes(s)).length;
  const totalTags = new Set([...refStyles, ...candidateStyles]).size;
  const styleScore = totalTags > 0
    ? Math.round((overlap / totalTags) * STYLE_MAX_SCORE)
    : 0;
  if (overlap > 0) {
    reasons.push(`스타일 키워드 일치`);
  }

  // Bonus: fit(3) + pattern(3) + subcategory(4)
  let bonusScore = 0;
  if (ref.fit && candidate.fit && ref.fit === candidate.fit) {
    bonusScore += 3;
    reasons.push(`${fitToKorean(ref.fit)} 핏 일치`);
  }
  if (ref.pattern && candidate.pattern && ref.pattern === candidate.pattern) {
    bonusScore += 3;
  }
  if (ref.subcategory && candidate.subcategory &&
      ref.subcategory === candidate.subcategory) {
    bonusScore += 4;
    reasons.push(`같은 ${candidate.subcategory} 타입`);
  }

  const score = categoryScore + colorScore + styleScore + Math.min(bonusScore, BONUS_MAX_SCORE);

  return {
    score,
    breakdown: {
      category: categoryScore,
      color: colorScore,
      style: styleScore,
      bonus: Math.min(bonusScore, BONUS_MAX_SCORE),
    },
    reasons,
  };
}

function deltaEToScore(deltaE: number): number {
  // TDD Section 6.2 mapping
  if (deltaE < 5) return 28 + Math.round((5 - deltaE) / 5 * 2);    // 28~30
  if (deltaE < 15) return 20 + Math.round((15 - deltaE) / 10 * 8);  // 20~28
  if (deltaE < 30) return 10 + Math.round((30 - deltaE) / 15 * 10); // 10~20
  return Math.max(0, Math.round((50 - deltaE) / 20 * 10));           // 0~10
}

function buildGapItem(ref: RefItem): GapResult {
  const colorName = ref.color?.name || "";
  const subcategory = ref.subcategory || categoryToKorean(ref.category);
  const description = `${colorName} ${subcategory}`;

  return {
    ref_index: ref.index,
    category: ref.category,
    description: description.trim(),
    search_keywords: `${colorName} ${subcategory}`.trim(),
  };
}

function categoryToKorean(cat: string): string {
  const map: Record<string, string> = {
    tops: "상의", bottoms: "하의", outerwear: "아우터",
    dresses: "원피스", shoes: "신발", bags: "가방", accessories: "액세서리",
  };
  return map[cat] || cat;
}

function fitToKorean(fit: string): string {
  const map: Record<string, string> = {
    oversized: "오버사이즈", regular: "레귤러", slim: "슬림",
  };
  return map[fit] || fit;
}
```

### 3.4 Color Utils (CIEDE2000)

```typescript
// supabase/functions/_shared/color-utils.ts

// HSL → L*a*b* → CIEDE2000
// Based on TDD Section 6.2

interface HSL { h: number; s: number; l: number; }
interface Lab { L: number; a: number; b: number; }

/** Convert HSL to RGB */
function hslToRgb(h: number, s: number, l: number): [number, number, number] {
  s /= 100; l /= 100;
  const c = (1 - Math.abs(2 * l - 1)) * s;
  const x = c * (1 - Math.abs((h / 60) % 2 - 1));
  const m = l - c / 2;

  let r = 0, g = 0, b = 0;
  if (h < 60) { r = c; g = x; }
  else if (h < 120) { r = x; g = c; }
  else if (h < 180) { g = c; b = x; }
  else if (h < 240) { g = x; b = c; }
  else if (h < 300) { r = x; b = c; }
  else { r = c; b = x; }

  return [
    Math.round((r + m) * 255),
    Math.round((g + m) * 255),
    Math.round((b + m) * 255),
  ];
}

/** Convert RGB to CIE L*a*b* */
function rgbToLab(r: number, g: number, b: number): Lab {
  // Normalize to 0-1 and apply gamma
  let rr = r / 255; let gg = g / 255; let bb = b / 255;
  rr = rr > 0.04045 ? Math.pow((rr + 0.055) / 1.055, 2.4) : rr / 12.92;
  gg = gg > 0.04045 ? Math.pow((gg + 0.055) / 1.055, 2.4) : gg / 12.92;
  bb = bb > 0.04045 ? Math.pow((bb + 0.055) / 1.055, 2.4) : bb / 12.92;

  // RGB to XYZ (D65)
  let x = (rr * 0.4124564 + gg * 0.3575761 + bb * 0.1804375) / 0.95047;
  let y = (rr * 0.2126729 + gg * 0.7151522 + bb * 0.0721750) / 1.00000;
  let z = (rr * 0.0193339 + gg * 0.1191920 + bb * 0.9503041) / 1.08883;

  const f = (t: number) => t > 0.008856 ? Math.cbrt(t) : (7.787 * t + 16 / 116);
  x = f(x); y = f(y); z = f(z);

  return {
    L: 116 * y - 16,
    a: 500 * (x - y),
    b: 200 * (y - z),
  };
}

/** CIEDE2000 color difference */
export function ciede2000(hsl1: HSL, hsl2: HSL): number {
  const [r1, g1, b1] = hslToRgb(hsl1.h, hsl1.s, hsl1.l);
  const [r2, g2, b2] = hslToRgb(hsl2.h, hsl2.s, hsl2.l);
  const lab1 = rgbToLab(r1, g1, b1);
  const lab2 = rgbToLab(r2, g2, b2);

  // CIEDE2000 implementation
  const { L: L1, a: a1, b: b1_ } = lab1;
  const { L: L2, a: a2, b: b2_ } = lab2;

  const avgL = (L1 + L2) / 2;
  const C1 = Math.sqrt(a1 * a1 + b1_ * b1_);
  const C2 = Math.sqrt(a2 * a2 + b2_ * b2_);
  const avgC = (C1 + C2) / 2;

  const G = 0.5 * (1 - Math.sqrt(Math.pow(avgC, 7) / (Math.pow(avgC, 7) + Math.pow(25, 7))));
  const a1p = a1 * (1 + G);
  const a2p = a2 * (1 + G);

  const C1p = Math.sqrt(a1p * a1p + b1_ * b1_);
  const C2p = Math.sqrt(a2p * a2p + b2_ * b2_);
  const avgCp = (C1p + C2p) / 2;

  let h1p = Math.atan2(b1_, a1p) * 180 / Math.PI;
  if (h1p < 0) h1p += 360;
  let h2p = Math.atan2(b2_, a2p) * 180 / Math.PI;
  if (h2p < 0) h2p += 360;

  let avgHp: number;
  if (Math.abs(h1p - h2p) > 180) {
    avgHp = (h1p + h2p + 360) / 2;
  } else {
    avgHp = (h1p + h2p) / 2;
  }

  const T = 1
    - 0.17 * Math.cos((avgHp - 30) * Math.PI / 180)
    + 0.24 * Math.cos((2 * avgHp) * Math.PI / 180)
    + 0.32 * Math.cos((3 * avgHp + 6) * Math.PI / 180)
    - 0.20 * Math.cos((4 * avgHp - 63) * Math.PI / 180);

  let dhp: number;
  if (Math.abs(h2p - h1p) <= 180) {
    dhp = h2p - h1p;
  } else if (h2p - h1p > 180) {
    dhp = h2p - h1p - 360;
  } else {
    dhp = h2p - h1p + 360;
  }

  const dLp = L2 - L1;
  const dCp = C2p - C1p;
  const dHp = 2 * Math.sqrt(C1p * C2p) * Math.sin(dhp / 2 * Math.PI / 180);

  const SL = 1 + 0.015 * Math.pow(avgL - 50, 2) / Math.sqrt(20 + Math.pow(avgL - 50, 2));
  const SC = 1 + 0.045 * avgCp;
  const SH = 1 + 0.015 * avgCp * T;

  const RT_exp = Math.pow(avgHp - 275, 2) / 625;
  const RC = 2 * Math.sqrt(Math.pow(avgCp, 7) / (Math.pow(avgCp, 7) + Math.pow(25, 7)));
  const RT = -Math.sin(2 * 30 * Math.exp(-RT_exp) * Math.PI / 180) * RC;

  const dE = Math.sqrt(
    Math.pow(dLp / SL, 2) +
    Math.pow(dCp / SC, 2) +
    Math.pow(dHp / SH, 2) +
    RT * (dCp / SC) * (dHp / SH)
  );

  return dE;
}
```

### 3.5 Deeplink Generator

```typescript
// supabase/functions/_shared/deeplink-generator.ts

interface Deeplinks {
  musinsa: string;
  ably: string;
  zigzag: string;
}

export function generateDeeplinks(keywords: string): Deeplinks {
  const encoded = encodeURIComponent(keywords);
  return {
    musinsa: `https://www.musinsa.com/search/musinsa/goods?q=${encoded}`,
    ably: `https://m.a-bly.com/search?keyword=${encoded}`,
    zigzag: `https://zigzag.kr/search?keyword=${encoded}`,
  };
}
```

---

## 4. Providers (Client - Riverpod)

### 4.1 Recreation Provider

```dart
// lib/features/recreation/providers/recreation_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/look_recreation.dart';
import '../data/recreation_repository.dart';

/// Repository singleton
final recreationRepositoryProvider = Provider<RecreationRepository>((ref) {
  return RecreationRepository();
});

/// Recreation history list
final recreationHistoryProvider =
    FutureProvider<List<LookRecreation>>((ref) async {
  final repo = ref.watch(recreationRepositoryProvider);
  return repo.fetchHistory();
});

/// Single recreation by ID
final recreationByIdProvider =
    FutureProvider.family<LookRecreation, String>((ref, id) async {
  final repo = ref.watch(recreationRepositoryProvider);
  return repo.fetchById(id);
});
```

### 4.2 Usage Provider

```dart
// lib/features/recreation/providers/usage_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import 'recreation_provider.dart';

/// Monthly recreation usage count
final recreationUsageProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(recreationRepositoryProvider);
  return repo.getMonthlyUsage();
});

/// Remaining free recreations this month
final remainingRecreationsProvider = FutureProvider<int>((ref) async {
  final used = await ref.watch(recreationUsageProvider.future);
  return (AppConfig.freeRecreationMonthlyLimit - used).clamp(0, AppConfig.freeRecreationMonthlyLimit);
});

/// Whether user can perform recreation
final canRecreateProvider = FutureProvider<bool>((ref) async {
  final remaining = await ref.watch(remainingRecreationsProvider.future);
  return remaining > 0;
  // TODO: Premium users always return true
});
```

### 4.3 Recreation Process Provider (State Machine)

```dart
// lib/features/recreation/providers/recreation_process_provider.dart
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/look_recreation.dart';
import '../data/recreation_repository.dart';
import 'recreation_provider.dart';
import 'usage_provider.dart';

/// Process state enum
enum RecreationStep {
  idle,            // Waiting for image selection
  uploading,       // Uploading image
  analyzing,       // Claude API analyzing
  matching,        // Matching engine running
  completed,       // Result ready
  error,           // Error occurred
}

/// Process state
class RecreationProcessState {
  final RecreationStep step;
  final Uint8List? imageBytes;
  final LookRecreation? result;
  final String? errorCode;
  final String? errorMessage;

  const RecreationProcessState({
    this.step = RecreationStep.idle,
    this.imageBytes,
    this.result,
    this.errorCode,
    this.errorMessage,
  });

  RecreationProcessState copyWith({
    RecreationStep? step,
    Uint8List? imageBytes,
    LookRecreation? result,
    String? errorCode,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return RecreationProcessState(
      step: step ?? this.step,
      imageBytes: imageBytes ?? this.imageBytes,
      result: clearResult ? null : (result ?? this.result),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Process notifier - manages the full recreation flow
class RecreationProcessNotifier extends StateNotifier<RecreationProcessState> {
  RecreationProcessNotifier(this._ref)
      : super(const RecreationProcessState());

  final Ref _ref;

  /// Set selected image and start analysis
  Future<void> startAnalysis(Uint8List imageBytes) async {
    state = state.copyWith(
      step: RecreationStep.uploading,
      imageBytes: imageBytes,
      clearError: true,
      clearResult: true,
    );

    try {
      final repo = _ref.read(recreationRepositoryProvider);

      // Simulate step progression for UX
      state = state.copyWith(step: RecreationStep.analyzing);

      // Call Edge Function (handles upload + AI + matching internally)
      final result = await repo.analyze(imageBytes);

      state = state.copyWith(
        step: RecreationStep.completed,
        result: result,
      );

      // Invalidate usage and history providers
      _ref.invalidate(recreationUsageProvider);
      _ref.invalidate(remainingRecreationsProvider);
      _ref.invalidate(canRecreateProvider);
      _ref.invalidate(recreationHistoryProvider);

    } on RecreationException catch (e) {
      state = state.copyWith(
        step: RecreationStep.error,
        errorCode: e.code,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        step: RecreationStep.error,
        errorCode: 'UNKNOWN_ERROR',
        errorMessage: e.toString(),
      );
    }
  }

  /// Reset to idle
  void reset() {
    state = const RecreationProcessState();
  }
}

final recreationProcessProvider = StateNotifierProvider.autoDispose<
    RecreationProcessNotifier, RecreationProcessState>(
  (ref) => RecreationProcessNotifier(ref),
);
```

---

## 5. UI Integration

### 5.1 S09 - ReferenceInputScreen

**Layout:**
```
┌────────────────────────────┐
│ AppBar: "룩 재현"           │
├────────────────────────────┤
│ 잔여 횟수: 3/5회           │  ← remainingRecreationsProvider
├────────────────────────────┤
│                            │
│  [점선 박스 300px]          │  ← 이미지 미선택 시 placeholder
│   ✨ 따라하고 싶은 코디     │     이미지 선택 시 preview
│   사진을 선택해주세요       │
│                            │
├────────────────────────────┤
│ [갤러리에서 선택] Primary   │  ← image_picker (gallery only)
│ Share Extension 안내 텍스트 │
├────────────────────────────┤
│ 최근 재현 히스토리          │  ← recreationHistoryProvider
│ [카드][카드][카드]          │     horizontal scroll
└────────────────────────────┘
```

**Key behaviors:**
- `image_picker` → `ImagePicker().pickImage(source: ImageSource.gallery)`
- 이미지 선택 후 → `context.push(AppRoutes.recreationAnalyzing)`
- 잔여 횟수 0이면 → "갤러리에서 선택" 버튼 disabled + 프리미엄 유도

### 5.2 S10 - AnalyzingScreen

**Layout:**
```
┌────────────────────────────┐
│ (no AppBar, full screen)    │
├────────────────────────────┤
│        [spinner]            │
│                            │
│      분석 중이에요          │
│                            │
│  ✅ 아이템 감지 완료        │  ← step >= analyzing
│  ✅ 색상/스타일 분석 완료   │  ← step >= matching
│  ⏳ 내 옷장에서 매칭 중...  │  ← step == matching
└────────────────────────────┘
```

**Key behaviors:**
- ConsumerStatefulWidget watching `recreationProcessProvider`
- `initState`: start timer-based fake step progression (0s → 감지, 1.5s → 분석, 3s → 매칭)
- On `step == completed` → `context.pushReplacement('/recreation/result/${result.id}')`
- On `step == error` → show error dialog with retry

### 5.3 S11 - ResultScreen

**Layout:**
```
┌────────────────────────────┐
│ ← 룩 재현 결과    매칭 78% │
├─────────────┬──────────────┤
│ 레퍼런스     │  내 재현 ✨   │  ← 나란히 비교 (Row)
│ [이미지]     │ [grid 2x2]  │
│              │ matched     │
│              │ items       │
├─────────────┴──────────────┤
│ 아이템 매칭 상세            │
│ ┌────────────────────────┐ │
│ │ ✅ 크림 니트 → 아이보리  │ │  ← MatchedItemCard
│ │    니트 92%             │ │
│ ├────────────────────────┤ │
│ │ ❌ 브라운 로퍼 [찾기]   │ │  ← GapItemCard
│ └────────────────────────┘ │
├────────────────────────────┤
│ [이미지 저장] [공유하기]    │  ← bottom actions
└────────────────────────────┘
```

**Key behaviors:**
- `ConsumerWidget` watching `recreationByIdProvider(recreationId)`
- Score badge color: >= 70 success green, 50-69 warning amber, < 50 error rose
- 매칭 아이템 탭 → `context.push('/wardrobe/${item.id}')`
- 갭 아이템 [찾기] → show `GapAnalysisSheet` as bottom sheet (not full screen)
- 전체 갭 시: "아직 매칭되는 아이템이 없어요" + "옷장에 추가하기" CTA

### 5.4 S12 - GapAnalysisSheet (Bottom Sheet)

**Change from current:** Convert from full-screen `Scaffold` to `showModalBottomSheet`.

**Layout:**
```
┌────────────────────────────┐
│ ─── (drag handle)          │
│ 이 아이템이 있으면 완벽해요! │
├────────────────────────────┤
│ [gap item description]     │
│ "브라운 캐주얼 로퍼"        │
├────────────────────────────┤
│ 🔍 무신사에서 찾기 →        │  ← url_launcher deeplink
│ 🔍 에이블리에서 찾기 →      │
│ 🔍 지그재그에서 찾기 →      │
└────────────────────────────┘
```

**Key behaviors:**
- Receives `GapItem` directly (not recreationId)
- Each link → `url_launcher` launchUrl with deeplink URL
- **Uses `url_launcher` package** (add to pubspec.yaml if missing)

### 5.5 Widgets

#### MatchedItemCard

```
┌──────────────────────────────────┐
│ [48x48 image]  크림 니트          │
│                → 아이보리 니트 92% │
│                색상 유사, 같은 핏  │  ← match_reasons
└──────────────────────────────────┘
Background: white
Border-left: 3px AppColors.success
```

#### GapItemCard

```
┌──────────────────────────────────┐
│ [48x48 ? icon]  브라운 로퍼       │
│                 없는 아이템       │
│                         [찾기 →] │
└──────────────────────────────────┘
Background: AppColors.gapCardBackground
Border-left: 3px AppColors.error
```

#### RecreationHistoryCard

```
┌──────────────────────────┐
│ [reference thumbnail]     │
│ 매칭 78%  ·  2시간 전     │
└──────────────────────────┘
Size: 140 x 180
Tap → context.push('/recreation/result/$id')
```

---

## 6. Navigation Flow

```
ReferenceInputScreen
  │ [갤러리에서 선택] → image_picker
  │ image selected
  ▼
  context.push('/recreation/analyzing')
  recreationProcessProvider.startAnalysis(imageBytes)

AnalyzingScreen
  │ watches recreationProcessProvider
  │ step == completed
  ▼
  context.pushReplacement('/recreation/result/${result.id}')

ResultScreen
  │ [찾기] on gap item
  ▼
  showModalBottomSheet → GapAnalysisSheet(gapItem: item)

ResultScreen
  │ ← back
  ▼
  context.pop() → ReferenceInputScreen (with updated history)
```

**Route change needed:** `AnalyzingScreen` needs access to `recreationProcessProvider` state. Since provider is `autoDispose`, ensure the analyzing route is pushed (not replaced) from input screen so the provider stays alive. Then analyzing screen does `pushReplacement` to result.

---

## 7. Storage Migration

New Supabase Storage bucket required for reference images:

```sql
-- supabase/migrations/20260223000002_create_reference_storage.sql
INSERT INTO storage.buckets (id, name, public)
VALUES ('reference-images', 'reference-images', false);

-- Allow authenticated users to upload to their own folder
CREATE POLICY "Users upload own references"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'reference-images'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow authenticated users to read their own references
CREATE POLICY "Users read own references"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'reference-images'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

---

## 8. Error Handling Matrix

| Error Code | HTTP | Trigger | User Message | UI Action |
|-----------|------|---------|-------------|-----------|
| `RECREATION_LIMIT_REACHED` | 403 | Monthly 5 uses exceeded | "이번 달 무료 룩 재현을 모두 사용했어요" | Premium bottom sheet |
| `INVALID_IMAGE` | 400 | Image parsing failed | "이미지를 처리할 수 없어요" | Back to input |
| `NO_FASHION_ITEMS` | 422 | No fashion items in image | "패션 아이템을 찾을 수 없어요.\n사람이 옷을 입은 사진을 선택해주세요" | [다른 이미지 선택] button |
| `AI_TIMEOUT` | 408 | Claude > 10s | "분석 시간이 초과됐어요" | [다시 시도] button |
| `AI_ERROR` | 502 | Claude API failure | "일시적인 오류가 발생했어요" | [다시 시도] button |
| `AUTH_REQUIRED` | 401 | Token expired | (auto redirect) | Login screen |
| `UNKNOWN_ERROR` | 500 | Unexpected | "알 수 없는 오류가 발생했어요" | [다시 시도] button |

**Error Dialog Pattern:**
```dart
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: Text(errorTitle),
    content: Text(errorMessage),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
      ElevatedButton(onPressed: retryCallback, child: Text(actionLabel)),
    ],
  ),
);
```

---

## 9. Dependencies to Add

```yaml
# pubspec.yaml additions
dependencies:
  url_launcher: ^6.2.0    # For deeplink opening (gap analysis)
```

`image_picker` and `supabase_flutter` are already present.

---

## 10. Implementation Order (Build Sequence)

```
Step 1: Models (1.1~1.4)
  └─ freezed models → run build_runner
Step 2: Storage migration (Section 7)
  └─ reference-images bucket
Step 3: Edge Function shared modules (3.4 → 3.5 → 3.3 → 3.2)
  └─ color-utils → deeplink-generator → matching-engine → claude-client
Step 4: Edge Function main handler (3.1)
  └─ recreate-analyze/index.ts
Step 5: Repository (Section 2)
  └─ recreation_repository.dart
Step 6: Providers (4.1 → 4.2 → 4.3)
  └─ recreation_provider → usage_provider → recreation_process_provider
Step 7: UI Widgets (5.5)
  └─ MatchedItemCard, GapItemCard, RecreationHistoryCard
Step 8: Screens (5.1 → 5.2 → 5.3 → 5.4)
  └─ ReferenceInputScreen → AnalyzingScreen → ResultScreen → GapAnalysisSheet
Step 9: Error handling integration (Section 8)
Step 10: url_launcher dependency + testing
```

---

## 11. Key Design Decisions

| Decision | Choice | Rationale |
|---------|--------|-----------|
| Image transfer to Edge Function | Base64 in JSON body | Simpler than multipart. Image < 10MB → base64 ~13MB, within Edge Function limits |
| CIEDE2000 implementation | Custom TypeScript | No Deno-compatible `delta-e` package; formula is well-documented |
| GapAnalysisSheet | Bottom sheet (not full screen) | Keeps context of result screen visible; matches UI/UX doc |
| Provider pattern | `StateNotifier` for process | Multi-step async process needs explicit state machine |
| History in ReferenceInputScreen | Horizontal scroll cards | Reuses screen real estate; encourages re-engagement |
| Error retry | Re-invoke `startAnalysis` with same bytes | No need to re-select image on transient errors |
| AnalyzingScreen fake steps | Timer-based progression | Real API is single call; fake steps reduce perceived wait time |
