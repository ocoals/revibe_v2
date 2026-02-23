# Design: Background Removal (배경 제거)

> Plan: `docs/01-plan/features/background-removal.plan.md`

## 1. System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Flutter App                          │
│                                                             │
│  ┌──────────────────┐    ┌──────────────────────────────┐   │
│  │  confirm_screen   │    │  item_registration_provider  │   │
│  │  (F1 Onboarding)  │    │  (F3 Manual Add)             │   │
│  └───────┬──────────┘    └───────────┬──────────────────┘   │
│          │                           │                      │
│          └─────────┬─────────────────┘                      │
│                    ▼                                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │          BackgroundRemovalService                     │   │
│  │  removeBackground(imageBytes) → Uint8List             │   │
│  └───────────────────────┬──────────────────────────────┘   │
│                          │ Supabase Functions.invoke()       │
└──────────────────────────┼──────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│              Supabase Edge Function                          │
│              POST /functions/v1/remove-background             │
│                                                              │
│  1. Auth check (JWT)                                         │
│  2. Decode base64 image                                      │
│  3. Call remove.bg API                                       │
│     ├─ Success → return processed PNG base64                 │
│     └─ Failure → return original image + fallback flag       │
│  4. Log result                                               │
└──────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│                     remove.bg API                            │
│              POST https://api.remove.bg/v1.0/removebg        │
│              Header: X-Api-Key: {REMOVE_BG_API_KEY}          │
│              Body: image_file_b64, size=auto                 │
│              Response: PNG binary                            │
└──────────────────────────────────────────────────────────────┘
```

## 2. Edge Function: `remove-background`

### 2.1 File Structure

```
supabase/functions/remove-background/
└── index.ts
```

### 2.2 Implementation

```typescript
// supabase/functions/remove-background/index.ts

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
```

### 2.3 Secrets Required

```bash
supabase secrets set REMOVE_BG_API_KEY=your_api_key_here
```

## 3. Flutter Service: `BackgroundRemovalService`

### 3.1 File

```
lib/core/services/background_removal_service.dart
```

### 3.2 Implementation

```dart
// lib/core/services/background_removal_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class BackgroundRemovalResult {
  final Uint8List imageBytes;
  final bool usedFallback;

  const BackgroundRemovalResult({
    required this.imageBytes,
    required this.usedFallback,
  });
}

class BackgroundRemovalService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Remove background from image via Edge Function.
  /// Returns processed image bytes, or original on failure.
  Future<BackgroundRemovalResult> removeBackground(
    Uint8List imageBytes,
  ) async {
    try {
      final response = await _client.functions.invoke(
        'remove-background',
        body: {
          'image_base64': base64Encode(imageBytes),
        },
      );

      if (response.status != 200) {
        debugPrint('Background removal failed: status=${response.status}');
        return BackgroundRemovalResult(
          imageBytes: imageBytes,
          usedFallback: true,
        );
      }

      final data = response.data as Map<String, dynamic>;
      final resultBase64 = data['image_base64'] as String;
      final usedFallback = data['used_fallback'] as bool? ?? false;

      return BackgroundRemovalResult(
        imageBytes: base64Decode(resultBase64),
        usedFallback: usedFallback,
      );
    } catch (e) {
      debugPrint('Background removal error: $e');
      return BackgroundRemovalResult(
        imageBytes: imageBytes,
        usedFallback: true,
      );
    }
  }
}
```

### 3.3 Provider

```dart
// Add to lib/core/services/background_removal_service.dart (bottom)

import 'package:flutter_riverpod/flutter_riverpod.dart';

final backgroundRemovalServiceProvider = Provider<BackgroundRemovalService>(
  (ref) => BackgroundRemovalService(),
);
```

## 4. Integration Points

### 4.1 WardrobeRepository Changes

```dart
// lib/features/wardrobe/data/wardrobe_repository.dart
// Add new method for PNG upload

/// Upload processed (background-removed) image as PNG
Future<String> uploadProcessedImage(
  String userId,
  Uint8List imageBytes,
  String fileName,
) async {
  final path = '$userId/$fileName';
  await _client.storage.from(_bucket).uploadBinary(
    path,
    imageBytes,
    fileOptions: const FileOptions(
      contentType: 'image/png',
      upsert: true,
    ),
  );
  return _client.storage.from(_bucket).getPublicUrl(path);
}
```

### 4.2 Item Registration Provider (F3 Manual Add)

```dart
// lib/features/wardrobe/providers/item_registration_provider.dart
// Modify submit() method

Future<bool> submit() async {
  // ... existing validation ...

  state = state.copyWith(isSubmitting: true, clearError: true);

  try {
    final repo = _ref.read(wardrobeRepositoryProvider);
    final bgService = _ref.read(backgroundRemovalServiceProvider);

    // NEW: Remove background before upload
    final bgResult = await bgService.removeBackground(imageBytes);

    // Upload with appropriate format
    final String imageUrl;
    if (bgResult.usedFallback) {
      // Fallback: upload original JPEG
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      imageUrl = await repo.uploadImage(user.id, bgResult.imageBytes, fileName);
    } else {
      // Success: upload processed PNG
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_processed.png';
      imageUrl = await repo.uploadProcessedImage(
        user.id, bgResult.imageBytes, fileName,
      );
    }

    // ... rest of submit (build data, createItem, invalidate) ...
  }
}
```

### 4.3 Confirm Screen (F1 Onboarding)

```dart
// lib/features/onboarding/presentation/confirm_screen.dart
// Modify _saveAndComplete() method

Future<void> _saveAndComplete() async {
  // ... existing validation ...

  setState(() => _isSaving = true);

  try {
    final repo = ref.read(wardrobeRepositoryProvider);
    final bgService = ref.read(backgroundRemovalServiceProvider);
    final imageBytes = analyzeState.imageBytes;

    // NEW: Remove background from shared image
    String? imageUrl;
    if (imageBytes != null) {
      final bgResult = await bgService.removeBackground(imageBytes);

      if (bgResult.usedFallback) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await repo.uploadImage(user.id, bgResult.imageBytes, fileName);
      } else {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_processed.png';
        imageUrl = await repo.uploadProcessedImage(
          user.id, bgResult.imageBytes, fileName,
        );
      }
    }

    // Save each selected item with the processed image URL
    for (final item in selectedItems) {
      final data = <String, dynamic>{
        'user_id': user.id,
        'image_url': imageUrl ?? '',
        // ... rest of fields unchanged ...
      };
      await repo.createItem(data);
    }

    // ... rest unchanged (invalidate, complete onboarding, show dialog) ...
  }
}
```

## 5. File Changes Summary

### 5.1 New Files

| # | File | Description |
|---|------|-------------|
| 1 | `supabase/functions/remove-background/index.ts` | Edge Function: remove.bg API proxy |
| 2 | `lib/core/services/background_removal_service.dart` | Flutter service + provider |

### 5.2 Modified Files

| # | File | Change |
|---|------|--------|
| 3 | `lib/features/wardrobe/data/wardrobe_repository.dart` | Add `uploadProcessedImage()` method |
| 4 | `lib/features/wardrobe/providers/item_registration_provider.dart` | Call background removal before upload in `submit()` |
| 5 | `lib/features/onboarding/presentation/confirm_screen.dart` | Call background removal before upload in `_saveAndComplete()` |

### 5.3 No Changes Needed

| File | Reason |
|------|--------|
| `wardrobe_grid_item.dart` | `CachedNetworkImage` renders PNG/JPEG transparently |
| `item_detail_screen.dart` | Same - image URL just changes to PNG |
| `matched_item_card.dart` | Same - reads `imageUrl` from wardrobe_item |
| `wardrobe_item.dart` (model) | `image_url` field unchanged, just different URL |
| DB schema (`wardrobe_items`) | `image_url TEXT` works for both JPEG/PNG URLs |

## 6. Implementation Order

```
Step 1: Edge Function (new file)
  └── supabase/functions/remove-background/index.ts

Step 2: Flutter Service (new file)
  └── lib/core/services/background_removal_service.dart

Step 3: Repository Extension (modify)
  └── wardrobe_repository.dart + uploadProcessedImage()

Step 4: F3 Integration (modify)
  └── item_registration_provider.dart submit()

Step 5: F1 Integration (modify)
  └── confirm_screen.dart _saveAndComplete()

Step 6: Verification
  └── flutter analyze
```

## 7. Error Handling Matrix

| Scenario | Edge Function | Flutter Service | User Impact |
|----------|:---:|:---:|---|
| remove.bg API key missing | Return original + `used_fallback: true` | Pass through | None (original image saved) |
| remove.bg API error (4xx/5xx) | Return original + `used_fallback: true` | Pass through | None |
| remove.bg timeout (>10s) | AbortController → return original | Pass through | None |
| Edge Function error (500) | Return error JSON | Catch → return original | None |
| Edge Function unreachable | N/A | Catch → return original | None |
| Network error | N/A | Catch → return original | None |

**Core principle**: Background removal failure NEVER blocks item registration.

## 8. Data Flow

### 8.1 Success Path

```
imageBytes (JPEG, ~500KB)
  → base64Encode → Edge Function
  → remove.bg API → PNG binary
  → base64 response → base64Decode
  → Uint8List (PNG, ~200KB)
  → uploadProcessedImage() → Storage
  → Public URL → wardrobe_items.image_url
```

### 8.2 Fallback Path

```
imageBytes (JPEG, ~500KB)
  → base64Encode → Edge Function
  → remove.bg fails → original base64 returned
  → base64Decode → original Uint8List
  → uploadImage() → Storage (JPEG)
  → Public URL → wardrobe_items.image_url
```

## 9. Testing Checklist

- [ ] Edge Function deploys successfully
- [ ] API key secret is set
- [ ] F1 onboarding: photo → background removed → saved to wardrobe
- [ ] F3 manual add: photo → background removed → saved to wardrobe
- [ ] Fallback: disable API key → original image saved
- [ ] Wardrobe grid displays processed images correctly
- [ ] Matched item cards show processed images
- [ ] `flutter analyze` passes with no issues
