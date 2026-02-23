# ClosetIQ Changelog

> **Project**: ClosetIQ v0.1.0
> **Last Updated**: 2026-02-23

---

## [2026-02-23] - project-setup PDCA Cycle #1 Completed (v1.0)

### Added

- **Flutter + Riverpod + GoRouter + Supabase** project foundation
  - Feature-first folder structure (core/, features/, shared/)
  - Riverpod StateProvider, StateNotifierProvider, FutureProvider patterns
  - GoRouter with ShellRoute for bottom navigation (홈/옷장/룩재현/마이)
  - Supabase local dev environment (Docker setup)

- **F0 Authentication**
  - Kakao OAuth login with kakao_flutter_sdk
  - Apple Sign-in with sign_in_with_apple
  - Email login/signup with validation (6+ char password, @ in email)
  - JWT token-based auth via Supabase
  - Auth state management (StreamProvider for user state)
  - Profile auto-creation trigger on signup
  - Logout functionality

- **F1 Onboarding**
  - Welcome screen with 3-slide PageView
  - Slide content: "내 옷장을 AI로 관리해요" / "인플루언서 룩을 내 옷으로" / "시작은 오늘 입은 옷 한 장"
  - Page indicators (animated dots)
  - Skip button on first/second slides
  - "Later" button on last slide
  - CTA: "오늘 입은 옷 찍기" button to capture screen
  - Onboarding completion routing with cache strategy (_cachedOnboardingCompleted)
  - Capture screen (skeleton: camera integration TODO)
  - Confirm screen (skeleton: item recognition TODO)

- **F3 Wardrobe Management (Core Feature - Complete)**
  - Repository pattern (WardrobeRepository with CRUD + Storage upload)
  - Riverpod providers:
    - wardrobeItemsProvider (FutureProvider from Supabase)
    - wardrobeCountProvider (FutureProvider for total count)
    - wardrobeCategoryFilterProvider (StateProvider)
    - filteredWardrobeItemsProvider (computed)
    - canAddItemProvider (free limit check)
    - itemRegistrationProvider (StateNotifierProvider for form)
  - Wardrobe screen (S06):
    - 3-column grid with CachedNetworkImage
    - Category filter chips (전체 + 7 categories)
    - Free tier limit progress bar (30 items)
    - Pull-to-refresh (RefreshIndicator)
    - Empty state UI
    - Loading skeleton grid
    - Error state with retry button
  - Item add screen (S08):
    - Image picker (camera + gallery)
    - Image processing (resize to 2048px, JPEG q85, EXIF removal)
    - Free tier limit check with SnackBar warning
  - Item register screen (form):
    - Category selector (7 main + 36 sub)
    - Subcategory dropdown
    - Color selector (25 fashion colors with names)
    - Fit selector (3 options via ChipOptionSelector)
    - Pattern selector (7 options via ChipOptionSelector)
    - Brand text input
    - Season multi-selector (4 seasons)
    - Submit button with validation
  - Item detail screen (S07):
    - Image display
    - Category + subcategory
    - Color with hex display
    - Fit, Pattern, Brand, Season metadata
    - Soft delete with confirmation dialog
    - Delete confirmation (AlertDialog)
  - Reusable widgets:
    - CategorySelector (FilterChip group)
    - SubcategorySelector (dropdown)
    - ColorSelector (Wrap with 25 colors + labels)
    - ChipOptionSelector (generic multi/single chip selector)
    - SeasonSelector (multi-select FilterChip)
    - WardrobeGridItem (grid tile with category badge + color dot)

- **F2 Look Recreation (Skeleton)**
  - Reference input screen (skeleton)
  - Analyzing screen with loading indicator (skeleton)
  - Result comparison screen (skeleton)
  - Gap analysis bottom sheet (skeleton)

- **Database**
  - Tier 1 Supabase tables (RLS enabled):
    - profiles (7 fields: id, user_id, avatar_url, onboarding_completed, subscription_tier, created_at, updated_at)
    - wardrobe_items (20 fields with metadata)
    - look_recreations (8 fields for result tracking)
    - usage_counters (4 fields for free tier limits)
  - Tier 2 tables (schema only): daily_outfits, outfit_items, subscriptions
  - Supabase Storage:
    - wardrobe-images bucket
    - 4 RLS policies (SELECT/INSERT/UPDATE/DELETE per user)
    - File size limit: 10MB
    - MIME types: JPEG, PNG, WebP

- **Design System**
  - Material 3 Dark theme
  - AppColors design tokens (14 base colors)
  - Typography (Headline, Title, Body, Caption)
  - Component styles
  - 25-color fashion palette mapping (hex → Korean name)

- **Additional Features (Beyond Design)**
  - OfflineBanner widget for network status
  - LoadingIndicator shared widget
  - Shimmer package for skeleton loading
  - ImageUtils with EXIF removal
  - ColorUtils with hex-to-Korean name mapping
  - Email signup validation
  - Onboarding completion cache strategy

### Changed

- Route ordering: moved literal paths (/wardrobe/add) before parameterized paths (/wardrobe/:id)
- ColorSelector: changed from GridView to Wrap for better label layout
- Item register form: changed from Column to ListView for scrolling support
- Onboarding routing: added cache to prevent repeated checks

### Fixed

- Onboarding routing loop (Major gap M1): added _isOnboardingCompleted() with cache
- Welcome slide single slide issue (Major gap M2): implemented 3-slide PageView
- Missing email login (Major gap M3): implemented signIn/signUpWithEmail with UI

### Analysis & Verification

- Gap Analysis v2.0: 97% match rate (up from 92% in v1.0)
- All v1.0 Major gaps (M1, M2, M3) resolved
- Remaining Minor gaps: 8 items (categorized by priority)
- E2E verification: 8/8 scenarios PASSED
  - Empty wardrobe UI
  - Add button navigation
  - Gallery image selection → register form
  - Category + color → submit → success
  - Grid display with metadata
  - Category filter chips
  - Item detail with all metadata
  - Delete with confirmation

### Known Issues / TODO

- S03 Capture screen: camera integration (image_picker preview)
- S04 Confirm screen: item recognition (image analysis)
- S11 Result screen: side-by-side comparison UI (complete skeleton)
- Item edit feature: PATCH endpoint + edit_screen not implemented
- styleTags: input UI not implemented (data exists, display needs UI)
- wearCount/lastWornAt: metadata not displayed in item detail
- Color/Season filters: not implemented in wardrobe screen
- Home screen: premium banner not implemented (Tier 2 feature)
- Button styles: Ghost/Dashed/Danger not in theme.dart
- WardrobeItem model: is_hidden_by_plan field missing (DB has it)

### Technical Debt

- Email validation: currently just checks for '@', needs RFC 5322
- Unit tests: missing for providers and repository
- Integration tests: missing for Supabase interactions
- Offline support: SQLite + Drift not implemented
- Supabase RLS: basic implementation, needs detailed testing

### Next Cycle Recommendations

1. **F2 Look Recreation Core** (Priority: High) — Expected 2-3 days
   - Complete S11 result screen with side-by-side comparison
   - Implement Claude Haiku API integration for matching
   - Dynamic gap analysis sheet generation

2. **F1 Onboarding Complete** (Priority: High) — Expected 1-2 days
   - S03 camera integration with live preview
   - S04 item recognition (crop + analysis)
   - Device permission handling

3. **F3 Wardrobe Enhancements** (Priority: Medium) — Expected 1-2 days
   - Item edit feature (PATCH + edit_screen)
   - Color and season filter expansion
   - styleTags input UI

4. **Technical Improvements** (Priority: Medium) — Expected 2-3 days
   - Unit tests for Provider and Repository
   - Email validation regex
   - Offline mode with SQLite

---

## Project Statistics

### Code Metrics

- **Total Files**: 80+
- **New Files (v1)**: 15+
- **Modified Files**: 12+
- **Lines of Code**: ~3,500 (lib/ code)
- **Test Coverage**: E2E 8 scenarios (Unit tests TODO)

### Feature Completeness

| Feature | Status | Match Rate | Priority |
|---------|--------|-----------|----------|
| F0 Authentication | Complete | 98% | Essential |
| F1 Onboarding | Partial | 75% | High |
| F2 Look Recreation | Skeleton | 20% | High |
| F3 Wardrobe | Complete | 97% | Essential |

### Quality Metrics

| Metric | Target | Achieved |
|--------|--------|----------|
| Design Match Rate | 90% | 97% ✅ |
| E2E Test Pass Rate | 100% | 100% ✅ |
| Code Architecture | Feature-first | 100% ✅ |
| RLS Compliance | 100% | 100% ✅ |

---

## Version Information

- **Project**: ClosetIQ
- **Version**: v0.1.0 (MVP)
- **Flutter**: 3.x+
- **Dart**: 3.x+
- **Database**: Supabase (PostgreSQL 15)
- **Auth**: Supabase JWT + OAuth

---

**Report**: See `/docs/04-report/project-setup.report.md` for detailed PDCA cycle analysis.
