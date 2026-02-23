import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { analyzeReference } from "../_shared/claude-client.ts";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  try {
    // 1. Auth check
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return errorResponse(401, "AUTH_REQUIRED", "Authorization required");
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_ANON_KEY") || Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const supabase = createClient(supabaseUrl, supabaseKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return errorResponse(401, "AUTH_REQUIRED", `Invalid token: ${authError?.message || "no user"}`);
    }

    // 2. Parse request body
    const body = await req.json();
    const imageBase64: string = body.image_base64;
    if (!imageBase64) {
      return errorResponse(400, "INVALID_IMAGE", "image_base64 is required");
    }

    // 3. Call Claude Haiku API for analysis
    console.log(`[onboarding-analyze] user=${user.id}, image_size=${imageBase64.length}`);
    const analysis = await analyzeReference(imageBase64);

    // 4. Validate
    if (!analysis.items || analysis.items.length === 0) {
      return errorResponse(422, "NO_FASHION_ITEMS", "No fashion items detected in image");
    }

    console.log(`[onboarding-analyze] ${analysis.items.length} items detected`);

    // 5. Return items directly (no DB record, no usage count, no matching)
    return new Response(JSON.stringify({
      items: analysis.items,
      overall_style: analysis.overall_style,
      occasion: analysis.occasion,
    }), {
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      status: 200,
    });

  } catch (err) {
    console.error("onboarding-analyze error:", err);
    return errorResponse(500, "INTERNAL_ERROR", `Internal server error: ${String(err)}`);
  }
});

function errorResponse(status: number, code: string, message: string) {
  return new Response(
    JSON.stringify({ error: message, code }),
    { headers: { ...CORS_HEADERS, "Content-Type": "application/json" }, status }
  );
}
