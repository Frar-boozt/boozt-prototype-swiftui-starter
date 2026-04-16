# SwiftUI Prototype Project — Boozt (Panda Design System)

This project is for rapid prototyping of SwiftUI screens that match the Boozt design language. The design system is documented in `design.md`. The SwiftUI token mappings live in `DesignSystem/`.

## Before Writing Any View

1. Read `design.md` to understand the Boozt visual identity.
2. Use the token extensions in `DesignSystem/` — never hardcode colors, font sizes, or spacing.
3. If the feature you're building maps to a layout pattern described in design.md (PLP, PDP, Homepage, etc.), follow that pattern closely.

## Design Identity — Non-Negotiables

- **0px corner radius on everything.** Buttons, cards, inputs, badges, containers — all sharp corners. This is the single most defining trait of Boozt's UI.
- **Near-black primary, warm off-white text.** CTA buttons use `Color.booztPrimary` (#241D26) with `Color.booztOnPrimary` (#FBF6F1). Not pure black, not pure white.
- **No shadows, no gradients, no rounded shapes.** Whitespace and typography do the work.
- **Red is for sales only.** `Color.booztError` is reserved for discounted prices and error states.
- **44px interactive element height.** Buttons, size selectors, filter chips — all 44px tall.
- **Warm neutrals for accent surfaces.** Use `Color.booztSurfaceContainer` (#EAE4DC), not cold grays.
- **Typography stays light.** Weights 400–500 for almost everything. Bold (700) only for rare promo banners.
- **Underlined text links** are the default.
- **Color selectors on PDP always use product thumbnail images**, never plain color dots or circles.

## Real Data via MapiService

The project includes `MapiService.swift` — a client for Boozt's mobile API (MAPI) that fetches real product data including images from `booztcdn.com`.

### Available methods
- `MapiService.shared.search(query:)` — Search for products by keyword. Returns `[ProductItem]`.
- `MapiService.shared.fetchProducts(navigationId:)` — Fetch products by navigation category ID. Returns `[ProductItem]`.

### ProductItem model
Both API methods return `ProductItem` which has: `brand`, `name`, `price`, `salePrice`, `imageURL`, `swatchColors`, `sizes`, `isOnSale`, `discountPercentage`, `formattedPrice`, `formattedSalePrice`.

### When to use real data vs mock data
- **Default to real data** when building screens that show product listings, search results, or product details. Use `AsyncImage(url: URL(string: item.imageURL))` for product images.
- **Fall back to mock data** for structural prototypes, offline work, or when the API is not relevant (e.g. checkout flow, account screens). Use `ProductItem.mock` or `ProductItem.mockProducts`.
- **Always include mock data in `#Preview`** blocks — previews can't make network calls.

### No auth required for basic usage
The search and navigation endpoints work without authentication. Auth (Apple Sign-In) is only needed for user-specific features.

## Code Conventions

### Architecture
- MVVM: each screen gets a View and a ViewModel in the same file.
- ViewModels are `@Observable` classes (iOS 17+).
- Keep views declarative — logic goes in the ViewModel.

### File Organization
- One file per screen: `FeatureNameView.swift` (View + ViewModel).
- Reusable components: `Components/`.
- Design tokens: `DesignSystem/` (Color+Boozt.swift, Font+Boozt.swift, Spacing.swift).
- API layer: `MapiService.swift`, `ProductItem.swift`, `Color+HexString.swift` (at project root).

### SwiftUI Patterns
- `#Preview` macro with mock data in every file.
- `NavigationStack`, not `NavigationView`.
- `@State` for local state, `@Environment` for DI.
- SF Symbols for icons (closest match to Boozt's icon style).
- `AsyncImage` for loading product images from URLs.

### Mock Data
- Every screen must render with realistic data — Danish product names, plausible prices in DKK, real-sounding brand names.
- Use `ProductItem.mock` / `ProductItem.mockProducts` for previews.
- No "Lorem ipsum" or placeholder text.

### What NOT To Do
- No unit tests.
- No third-party dependencies.
- No modifications to the App entry point unless navigation requires it.
- No border radius > 0 unless explicitly specified for a specific element.
