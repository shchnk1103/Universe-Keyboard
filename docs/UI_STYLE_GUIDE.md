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
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -destination 'generic/platform=iOS Simulator' build
```

If the build cannot run because of local Xcode or simulator state, state that clearly in the final note.

## Keyboard Extension

The keyboard extension lives under `Keyboard/` and is UIKit-based. It should resemble the native iOS keyboard more than a custom app panel.

### V1 UI Freeze

Keyboard UI is frozen for V1. Future keyboard UI changes must state a specific usability reason, such as reducing mistouches, fixing clipping, improving accessibility, or correcting a real interaction regression. Do not make cosmetic tuning changes during the freeze.

**Exception — Chinese nine-key chrome:** matching the system 九宫格 layout (5-column rhythm, letter-group primary labels, side function columns) is an authorized usability alignment under `KEYBOARD-LAYOUT-9KEY-UI-001`. It must not redesign 26-key QWERTY metrics or candidate-bar constants without a separate reason.

Frozen keyboard baseline:

- Keyboard content top inset: `2`.
- Keyboard content bottom inset: `0`.
- Candidate bar height: `34`.
- Candidate-to-key spacing: `8`.
- Letter key height: `45`.
- Function key width for Shift, Delete, 123, globe, and input-mode keys: `46`.
- Function key symbol size: `18`.
- Vertical row spacing: `8`.
- Letter-area to bottom-row group spacing: `10`.
- Third-row function-key to letter-group spacing: `10`.
- Within-row horizontal key spacing: `6`.
- Keyboard content horizontal margins: `7`.
- Key corner radius: near `9`, using continuous corners.

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

Keyboard keys must use the custom `KeyboardKeyButton` created by `makeKeyButton(...)`, not raw `UIButton(type: .system)`. The custom button expands touch tracking with a small slop area so fast typing is tolerant of slight finger drift.

Current key styles:

- `.character`: letters, numbers, and symbols.
- `.function`: globe, page switch, input mode, shift off, delete, and shortcut keys.
- `.space`: space key.
- `.returnKey`: return/search/go/send key.
- `.active`: strong active state such as caps lock.

Key rules:

- Keep letter key height at `45`.
- Keep primary function keys at `46` wide unless a usability issue requires a change.
- Keep vertical row spacing at `8`, letter-area to bottom-row group spacing at `10`, third-row function spacing at `10`, and within-row horizontal spacing at `6`.
- Keep keyboard content horizontal margins at `7`.
- Keep key corner radius near `9`; do not make keys pill-shaped.
- Character keys may have a subtle 1 px downward shadow.
- Function keys should be flatter and darker/lower-emphasis than character keys.
- Function key symbols should remain readable at the frozen `18` point size.
- Keep visual key gaps native-looking, but do not leave dead touch zones inside the key input area. Split key-area gaps at adjacent midlines into per-key touch cells through the root hit-test container instead of changing visible spacing. As with candidate cells, keep a nearly invisible backing view (`alpha` around `0.001`) for each expanded key touch cell; diagnostic visuals must not be the reason hit testing works.
- Press feedback should use brief background highlight plus subtle scale, not full alpha fading.
- Visual press state, key click, and haptic feedback should be emitted together from key touch-down for standard keys. Paths without a normal touch-down, such as candidate commit or long-press variant commit, should use the shared feedback helper at commit time.
- The middle letter row should stay slightly inset, matching native QWERTY rhythm.

### Candidate Bar

The candidate bar must prioritize readability and speed:

- The bar background should match the keyboard background.
- Do not add a card-like container or separator between the candidate bar and key rows unless a specific readability regression requires it.
- The first real candidate, such as `你好` after typing `nihao`, should be visually clear:
  - Text color: `.label`.
  - Weight: semibold.
  - Background: high-contrast pill drawn by `CandidateCollectionCell`.
- Composition/preedit fallback should use `.secondaryLabel`.
- Placeholder items should not appear as selectable candidates.
- The expand button should be quiet: SF Symbol, secondary color, fixed width only when candidates exist.
- Normal horizontal candidates use a 17pt base font; composition fallback uses 15pt. Keep Dynamic Type capped at 28pt so candidate rows do not resize unpredictably.
- Candidate cells should render text with `UILabel` and an explicit highlighted background view. Avoid `UIButton.Configuration` for candidate display; it can interact poorly with system material compositing.
- Candidate `UICollectionView`s must use `CandidateScrollViewStyle.apply(to:)`. On iOS 26+, `UIScrollEdgeEffect` can create a rectangular fade/overlay over the first candidate row inside the system keyboard glass container.
- Candidate `UICollectionView` layouts should avoid real spacing between items. Keep item spacing at zero, put the visual gap inside the cell, and keep a nearly invisible backing view (`alpha` around `0.001`) so the apparent gap remains part of a cell's touch area in the Keyboard Extension.
- Candidate expand and collapse chevrons may have a larger real hit area than their visible symbol. Do this through the button's own `point(inside:with:)` and nearly invisible backing, not through visible diagnostic overlays or red debug backgrounds.
- Candidate touch diagnostics should use the shared logger. Diagnostic logging must not change visible candidate or chevron styling; otherwise real-device hit testing can accidentally depend on the debug view.

Do not use tint-colored candidate text if it reduces contrast against the candidate background.

### Layout

Keyboard layout is built from `UIStackView` rows:

- Keep row construction in `KeyboardViewController+Layout.swift`.
- Keep style creation in `KeyboardViewController+KeyFactory.swift`.
- Keep candidate styling in `CandidateCell.swift` and candidate scroll-view safeguards in `CandidateScrollViewStyle.swift`.
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

- `AppActionButton`: main-app content actions such as download, deploy, retry, reset, and destructive management commands.
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
- Use `AppActionButton` for explicit in-page commands. Do not hand-style `.bordered` / `.borderedProminent` buttons for download, deploy, retry, reset, license acceptance, or destructive management actions unless a new reusable variant is added first.
- For dense management actions inside `Form` sections, prefer a two-column adaptive grid with stable full-width action buttons over a single horizontal button row. Button labels must remain one line at normal text sizes and avoid vertical wrapping on narrow devices.
- RIME deployment progress, success, and failure notifications should use the main-app global bottom toast instead of one-off page-local popups. Detail pages may keep logs and retry actions, but should not duplicate transient deployment notifications.
- RIME candidate-learning backup, restore, reset, and automatic-backup operation results should also use the global bottom toast. The settings page should show stable per-scheme status with short text and compact icons, not a persistent message section for the last operation.
- Multi-scheme RIME settings should scale as a scheme list with per-scheme detail pages when each scheme has multiple controls. Avoid repeating every scheme across separate feature sections such as learning, backup, and reset.
- Scheme-specific RIME actions belong on that scheme's detail page. Keep global settings, such as candidate count, simplification, and deployment status, at the top-level RIME settings page unless the setting truly belongs to one scheme.
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
- Reintroducing candidate scroll fade masks or leaving iOS 26 `UIScrollEdgeEffect` enabled on candidate lists.
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

Manual keyboard UI verification before changing the frozen baseline:

- Slow typing: press and hold a letter briefly, then release. Visual, click, and haptic feedback should feel like one event at touch-down.
- Rapid typing: type a short sequence quickly. System input clicks should remain natural, must not transfer Bluetooth route ownership, and the keyboard should remain responsive.
- Repeated key presses: press Shift, 123, input mode, Return, and Delete repeatedly. Feedback should not double-fire.
- Long-press delete: first delete should feel immediate; repeated deletes should keep a natural feedback rhythm.
- Edge keys: first and last keys in each row should not feel too close to the screen edge.
- Candidate commit: selecting candidates and expanded-panel candidates should keep readable candidate state and emit feedback once.
- Accessibility: VoiceOver labels remain semantic, and dynamic labels such as Return still fit.
