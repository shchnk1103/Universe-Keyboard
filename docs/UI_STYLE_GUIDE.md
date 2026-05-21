# Universe Keyboard UI Style Guide

This guide defines the visual rules for the main app and keyboard extension. It is written for both humans and AI agents. Before changing UI code, read this file and keep changes consistent with it.

## Goal

Universe Keyboard should feel close to the native iOS keyboard and native iOS Settings app:

- Quiet, functional, and system-like.
- High contrast in both light and dark mode.
- Compact enough for repeated typing and configuration.
- No decorative visual language that competes with the host app.

When in doubt, choose the more native-looking option over a more branded or expressive option.

## Required Workflow

For every UI change:

1. Identify whether the change affects the main app, the keyboard extension, or both.
2. Reuse existing components and style helpers before adding new one-off styling.
3. Preserve light and dark mode contrast.
4. Keep touch targets stable; dynamic content must not resize rows or keys unexpectedly.
5. Build after code changes:

```bash
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -destination 'platform=iOS Simulator,name=iPhone 17' build
```

If the build cannot run because of local Xcode or simulator state, state that clearly in the final note.

## Keyboard Extension

The keyboard extension lives under `Keyboard/` and is UIKit-based. It should resemble the native iOS keyboard more than a custom app panel.

### Color

Use semantic colors when possible, but keep the keyboard surface close to native iOS keyboard tones:

- Keyboard background: use `keyboardBackgroundColor`.
- Character key background: use `characterKeyColor`.
- Function key background: use `functionKeyColor`.
- Pressed key background: use `highlightedKeyColor`.
- Text on keys and candidates: prefer `.label` unless a secondary/de-emphasized state is intentional.
- Secondary text, composition text, and chrome: use `.secondaryLabel`.

Never use low-contrast colored text on a colored or translucent pill. Candidate text, especially the first candidate, must remain readable at a glance.

### Keys

Use `makeKeyButton(...)` and `applyKeyStyle(_:to:)` for all keyboard keys. Do not hand-style button colors, fonts, corner radii, or shadows at call sites unless a new reusable style is first added.

Current key styles:

- `.character`: letters, numbers, and symbols.
- `.function`: globe, page switch, input mode, shift off, delete, and shortcut keys.
- `.space`: space key.
- `.returnKey`: return/search/go/send key.
- `.active`: strong active state such as caps lock.

Key rules:

- Keep key height at `44`.
- Keep spacing at `6`.
- Keep key corner radius near `9`; do not make keys pill-shaped.
- Character keys may have a subtle 1 px downward shadow.
- Function keys should be flatter and darker/lower-emphasis than character keys.
- Press feedback should use brief background highlight plus subtle scale, not full alpha fading.
- The middle letter row should stay slightly inset, matching native QWERTY rhythm.

### Candidate Bar

The candidate bar must prioritize readability and speed:

- The bar background should match the keyboard background.
- Use a subtle separator instead of a card-like container.
- The first real candidate, such as `你好` after typing `nihao`, should be visually clear:
  - Text color: `.label`.
  - Weight: semibold.
  - Background: high-contrast pill via `CandidateButtonFactory`.
- Composition/preedit fallback should use `.secondaryLabel`.
- Placeholder items should not appear as selectable candidates.
- The expand button should be quiet: SF Symbol, secondary color, fixed width only when candidates exist.

Do not use tint-colored candidate text if it reduces contrast against the candidate background.

### Layout

Keyboard layout is built from `UIStackView` rows:

- Keep row construction in `KeyboardViewController+Layout.swift`.
- Keep style creation in `KeyboardViewController+KeyFactory.swift`.
- Keep candidate styling in `CandidateButtonFactory.swift`.
- Keep visual state refresh in `KeyboardViewController+Display.swift`.
- Keep press and long-press visuals in `KeyboardViewController+Gestures.swift`.

Avoid mixing business state and visual styling. Business logic belongs in `KeyboardCore`; the view controller should delegate actions to `KeyboardController.handle(_:)`.

## Main App

The main app lives under `Universe Keyboard/` and is SwiftUI-based. It should feel like a small companion Settings app, not a marketing page.

### Structure

- Use `NavigationStack` per tab.
- Use `TabView` only for the top-level Guide and Settings tabs.
- Prefer `Form` for detailed settings screens.
- Prefer grouped-background scroll layouts for guide/overview screens.
- Keep custom containers close to system grouped list appearance.

### Components

Reuse these components:

- `InfoSection`: grouped information sections.
- `SettingsNavigationLink`: settings-style navigation rows.
- `ToggleRow`: toggle plus explanatory text.
- `BulletRow`: concise feature/checklist rows.
- `CapsuleBadge`: small metadata badges.

Do not duplicate navigation row markup when `SettingsNavigationLink` fits.

### Visual Rules

- Use `Color(.systemGroupedBackground)` for screen backgrounds.
- Use `Color(.secondarySystemGroupedBackground)` for grouped containers.
- Use rounded rectangles with continuous corners around `10`.
- App/settings icon tiles should be small rounded squares, around `30x30`, with white SF Symbols.
- Keep spacing compact: roughly `14-16` horizontal screen padding and `12-16` between groups.
- Use `.blue` as the primary tint; use other system colors only for clear semantic categories.
- Avoid oversized hero sections, gradients, decorative illustrations, and promotional copy.

## Accessibility And Contrast

Every UI change must pass this mental checklist:

- Text and important symbols are readable in light mode.
- Text and important symbols are readable in dark mode.
- Candidate text remains readable while typing quickly.
- Dynamic labels such as return key titles fit their button.
- Buttons keep stable sizes across state changes.
- Internal state is not stored in accessibility labels, identifiers, or values unless it is genuinely accessibility-related.

## Common Mistakes To Avoid

- Making the keyboard look like an app toolbar instead of a native keyboard.
- Using brand blue for candidate text when it lowers contrast.
- Adding card backgrounds inside the keyboard surface.
- Styling one button directly instead of adding or reusing a key style.
- Adding large custom SwiftUI sections when a `Form` or existing component would be more native.
- Changing layout constants without checking keyboard height and row stability.
- Introducing decorative gradients, large rounded pills, or marketing-style copy.

## Review Checklist

Before considering a UI change complete:

- The relevant style guide section was followed.
- Existing components/helpers were reused.
- Light/dark contrast was considered explicitly.
- Keyboard candidate readability was preserved.
- The Xcode build command above succeeded, or the blocker was documented.
