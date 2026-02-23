import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const REMOVE_BG_URL = "https://api.remove.bg/v1.0/removebg";
const TIMEOUT_MS = 10_000;

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
    const supabaseKey =
      Deno.env.get("SUPABASE_ANON_KEY") ||
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const supabase = createClient(supabaseUrl, supabaseKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();
    if (authError || !user) {
      return errorResponse(401, "AUTH_REQUIRED", "Invalid token");
    }

    // 2. Parse request
    const body = await req.json();
    const imageBase64: string = body.image_base64;
    if (!imageBase64) {
      return errorResponse(400, "INVALID_IMAGE", "image_base64 is required");
    }

    console.log(
      `[remove-background] user=${user.id}, image_size=${imageBase64.length}`
    );

    // 3. Call remove.bg API
    const apiKey = Deno.env.get("REMOVE_BG_API_KEY");
    if (!apiKey) {
      console.warn("[remove-background] No API key, returning original");
      return successResponse(imageBase64, true);
    }

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), TIMEOUT_MS);

      const formData = new FormData();
      formData.append("image_file_b64", imageBase64);
      formData.append("size", "auto");

      const response = await fetch(REMOVE_BG_URL, {
        method: "POST",
        headers: { "X-Api-Key": apiKey },
        body: formData,
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        console.error(
          `[remove-background] API error: ${response.status} ${response.statusText}`
        );
        return successResponse(imageBase64, true);
      }

      // Convert PNG binary to base64
      const pngBuffer = await response.arrayBuffer();
      const pngBase64 = btoa(
        String.fromCharCode(...new Uint8Array(pngBuffer))
      );

      console.log(
        `[remove-background] Success, output_size=${pngBase64.length}`
      );
      return successResponse(pngBase64, false);
    } catch (err) {
      console.error(`[remove-background] API call failed: ${err}`);
      return successResponse(imageBase64, true);
    }
  } catch (err) {
    console.error("[remove-background] Unexpected error:", err);
    return errorResponse(500, "INTERNAL_ERROR", String(err));
  }
});

function successResponse(imageBase64: string, usedFallback: boolean) {
  return new Response(
    JSON.stringify({
      image_base64: imageBase64,
      used_fallback: usedFallback,
    }),
    {
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      status: 200,
    }
  );
}

function errorResponse(status: number, code: string, message: string) {
  return new Response(JSON.stringify({ error: message, code }), {
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    status,
  });
}
