---
description: Generate a SwiftUI prototype screen using the Boozt/Panda design system
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
argument-hint: <feature description>
---

Build a SwiftUI prototype for the following feature:

$ARGUMENTS

## Step 1: Load the design system

Read `CLAUDE.md` in the project root for the design identity rules and code conventions.

Then read `design.md` in the project root for the full design reference — component specs, color tokens, typography scale, spacing tokens, and page layout patterns.

## Step 2: Check the DesignSystem token files

Verify the project has these files:
- `DesignSystem/Color+Boozt.swift`
- `DesignSystem/Font+Boozt.swift`
- `DesignSystem/Spacing.swift`

If any are missing, stop and tell the user: "The DesignSystem/ token files are missing. Run the project setup first or copy them from the template."

## Step 3: Build the prototype

Generate the SwiftUI screen(s) for the requested feature:

1. **One file per screen**: `FeatureNameView.swift` with both the View and an `@Observable` ViewModel.
2. **Use the DesignSystem tokens everywhere** — `Color.booztPrimary`, `Font.booztTitleLarge`, `Spacing.m`, `ComponentSize.interactiveHeight`, `CornerRadius.sharp`. Never hardcode values.
3. **Follow the Boozt design identity**: 0px corners, no shadows, no gradients, 44px interactive elements, warm neutrals, near-black CTAs with warm off-white text.
4. **If the feature maps to a known Boozt page pattern** (PLP, PDP, Homepage, Category Landing Page) from design.md, follow that layout closely.
5. **For mobile/iOS screens**, follow the mobile layout patterns: single column, bottom tab bar, swipeable carousels, no sidebar.
6. **Include realistic Danish mock data** with prices in DKK, real brand names, and Danish UI labels.
7. **Add a `#Preview`** with mock data so the screen renders immediately in Xcode.
8. **Shared components** (product cards, filter chips, size selectors, badges, etc.) go in `Components/` — build them to the Boozt component specs from design.md.

## Step 4: Wire up navigation if needed

If the feature involves multiple screens or tabs:
- Create all screen files.
- Update or create a root navigation structure.
- Only modify the App entry point if strictly necessary for navigation.

## Step 5: Summary

After generating all files, list:
- Each file created and what it contains.
- Any new components added to `Components/`.
- Anything the user should check in Xcode (e.g., adding files to the target).
