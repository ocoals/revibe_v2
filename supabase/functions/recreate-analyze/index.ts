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
    console.log("[1/13] Auth check...");
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return errorResponse(401, "AUTH_REQUIRED", "Authorization required");
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_ANON_KEY") || Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    console.log(`[1/13] URL=${supabaseUrl}, keyPrefix=${supabaseKey?.substring(0, 15)}...`);

    const supabase = createClient(supabaseUrl, supabaseKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      console.error("[1/13] Auth failed:", authError?.message);
      return errorResponse(401, "AUTH_REQUIRED", `Invalid token: ${authError?.message || "no user"}`);
    }
    console.log(`[1/13] Auth OK: user=${user.id}`);

    // 2. Parse request body
    console.log("[2/13] Parsing body...");
    const body = await req.json();
    const imageBase64: string = body.image_base64;
    if (!imageBase64) {
      return errorResponse(400, "INVALID_IMAGE", "image_base64 is required");
    }
    console.log(`[2/13] Image size: ${imageBase64.length} chars`);

    // 3. Check usage limit
    console.log("[3/13] Checking usage...");
    const monthKey = getCurrentMonthKey();
    const usage = await getOrCreateUsage(supabase, user.id, monthKey);
    if (!usage) {
      console.error("[3/13] Failed to get/create usage record");
      return errorResponse(500, "INTERNAL_ERROR", "Failed to initialize usage counter");
    }
    console.log(`[3/13] Usage: ${usage.recreation_count}/${FREE_RECREATION_LIMIT}`);
    if (usage.recreation_count >= FREE_RECREATION_LIMIT) {
      return errorResponse(403, "RECREATION_LIMIT_REACHED",
        "Monthly free recreation limit reached");
    }

    // 4. Create pending record
    console.log("[4/13] Creating pending record...");
    const { data: pendingRecord, error: insertError } = await supabase
      .from("look_recreations")
      .insert({
        user_id: user.id,
        reference_image_url: "",
        reference_analysis: {},
        status: "pending",
      })
      .select()
      .single();
    if (insertError || !pendingRecord) {
      console.error("[4/13] Insert failed:", insertError?.message);
      return errorResponse(500, "INTERNAL_ERROR", `DB insert failed: ${insertError?.message}`);
    }
    console.log(`[4/13] Record created: ${pendingRecord.id}`);

    // 5. Upload reference image to storage
    console.log("[5/13] Uploading image...");
    const imageBuffer = base64ToUint8Array(imageBase64);
    const imagePath = `${user.id}/${pendingRecord.id}.jpg`;
    const { error: uploadError } = await supabase.storage
      .from("reference-images")
      .upload(imagePath, imageBuffer, { contentType: "image/jpeg", upsert: true });
    if (uploadError) {
      console.error("[5/13] Upload failed:", uploadError.message);
    }
    // Store the path, not the full URL (internal Docker URL is not accessible from client)
    const referenceImageUrl = imagePath;
    console.log(`[5/13] Upload done, path: ${referenceImageUrl}`);

    // 6. Call Claude Haiku API
    console.log("[6/13] Calling Claude API...");
    const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
    console.log(`[6/13] API key present: ${!!apiKey}, prefix: ${apiKey?.substring(0, 10)}...`);
    const referenceAnalysis = await analyzeReference(imageBase64);
    console.log(`[6/13] Claude OK: ${referenceAnalysis.items?.length} items detected`);

    // 7. Validate analysis
    if (!referenceAnalysis.items || referenceAnalysis.items.length === 0) {
      console.log("[7/13] No fashion items found");
      await updateRecordFailed(supabase, pendingRecord.id);
      return errorResponse(422, "NO_FASHION_ITEMS",
        "No fashion items detected in image");
    }
    console.log(`[7/13] Validation OK: ${referenceAnalysis.items.length} items`);

    // 8. Fetch user's wardrobe items
    console.log("[8/13] Fetching wardrobe...");
    const { data: wardrobeItems } = await supabase
      .from("wardrobe_items")
      .select("*")
      .eq("user_id", user.id)
      .eq("is_active", true);
    console.log(`[8/13] Wardrobe: ${wardrobeItems?.length || 0} items`);

    // 9. Run matching engine
    console.log("[9/13] Matching...");
    const { matchedItems, gapItems, overallScore } = matchItems(
      referenceAnalysis.items,
      wardrobeItems || []
    );
    console.log(`[9/13] Match: ${matchedItems.length} matched, ${gapItems.length} gaps, score=${overallScore}`);

    // 10. Generate deeplinks for gap items
    console.log("[10/13] Generating deeplinks...");
    const gapItemsWithLinks = gapItems.map((item) => ({
      ...item,
      deeplinks: generateDeeplinks(item.search_keywords),
    }));

    // 11. Update record to completed
    console.log("[11/13] Updating record...");
    const { data: result, error: updateError } = await supabase
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
    if (updateError) {
      console.error("[11/13] Update failed:", updateError.message);
    }
    console.log("[11/13] Record updated");

    // 12. Increment usage counter
    console.log("[12/13] Incrementing usage...");
    await supabase
      .from("usage_counters")
      .update({ recreation_count: usage.recreation_count + 1 })
      .eq("user_id", user.id)
      .eq("month_key", monthKey);

    // 13. Return result
    console.log("[13/13] Done! Returning result");
    return new Response(JSON.stringify(result), {
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      status: 200,
    });

  } catch (err) {
    console.error("recreate-analyze CRASH:", err);
    return errorResponse(500, "INTERNAL_ERROR", `Internal server error: ${String(err)}`);
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
