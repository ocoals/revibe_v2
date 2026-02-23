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

      return parseAndValidate(text);

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

  if (!Array.isArray(parsed.items)) {
    throw new Error("Invalid response: items array missing");
  }

  // Validate and sanitize each item
  parsed.items = parsed.items
    .filter((item: any) => VALID_CATEGORIES.includes(item.category))
    .map((item: any, i: number) => {
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
