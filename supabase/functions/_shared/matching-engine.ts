import { ciede2000 } from "./color-utils.ts";

const MATCH_THRESHOLD = 50;

const CATEGORY_SCORE = 40;
const COLOR_MAX_SCORE = 30;
const STYLE_MAX_SCORE = 20;
const BONUS_MAX_SCORE = 10; // fit(3) + pattern(3) + subcategory(4)

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

    // No candidates -> immediate gap
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
  if (deltaE < 5) return 28 + Math.round((5 - deltaE) / 5 * 2);     // 28~30
  if (deltaE < 15) return 20 + Math.round((15 - deltaE) / 10 * 8);   // 20~28
  if (deltaE < 30) return 10 + Math.round((30 - deltaE) / 15 * 10);  // 10~20
  return Math.max(0, Math.round((50 - deltaE) / 20 * 10));            // 0~10
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
