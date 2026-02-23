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
    // 1. Auth
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
      return errorResponse(403, "RECREATION_LIMIT_REACHED",
        "Monthly free recreation limit reached");
    }

    // 4. Create pending record
    const { data: pendingRecord } = await supabase
      .from("look_recreations")
      .insert({
        user_id: user.id,
        reference_image_url: "",
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
