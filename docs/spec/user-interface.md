# User Interface

A dark animated sky, large cards and, while playing, only the picture. Underneath, native system
containers, controls, text styles and SF Symbols; no hand-drawn system chrome. Shared pieces live
in `StarfoldShared/UserInterface/`; views use them by name, never raw values.

## Colour

Colours come from two places only: the `Palette` (brand, follows the person's choice) and
semantic `Color` extensions (status, card surfaces). Text uses `.primary` / `.secondary`; errors
use system red.

- Each palette (Nebula, the default; Aurora; Sunrise) sets the sky, the primary button and the
  accent. It is picked in Settings and applies at once, even mid-stream; an unknown value reads as
  Nebula. A new palette adds a `PaletteID` case with all its values.
- Every primary label meets 4.5:1 against its fill (tested).
- `primaryFill` is for the one main action, empty and error symbols, and focus outlines.
  `accent` replaces the system accent only where the system uses one (selection, switches,
  links), set as the window tint; system-neutral controls stay neutral. `primaryTint` is for
  prominent buttons, badges and the favourite heart; `night` colours are artwork placeholders.
- Brand colour never marks a state, colours list text, or appears in stream overlays (except a
  selected control).

| Semantic | Means |
|---|---|
| `online` | Console on, cloud available, latency < 50 ms |
| `standby` | Console asleep or off, free-to-play only |
| `attention` | Latency 50–90 ms, a failed stream or sign-in |
| System red | Latency > 90 ms, destructive actions |
| `cardFill`, `cardStroke` | Card surfaces over the sky |

A status colour always comes with words: visible text or a VoiceOver label.

## Buttons

| Style | Use |
|---|---|
| `.primary` (palette capsule; grows on hover, shrinks when pressed, desaturated when disabled) | The one main action |
| `.circleIcon` (circle, icon only) | Secondary card actions |
| `TileButtonStyle` (no chrome, lifts on hover) | Game artwork |
| System styles | Everything else, and all buttons on visionOS and tvOS |

An icon-only button has a VoiceOver label and, on the Mac, a tooltip with its shortcut.

## Sky

- `SkyBackground` is a Metal shader (gradient, glow, slow ribbons, a low frame rate), hidden from
  VoiceOver, behind the main pages, welcome, a console's waiting page and the Apple TV tabs.
- It freezes under Reduce Motion and, on the Mac, while its window is inactive.
- On iPhone and iPad it is drawn at window size from the top, so the keyboard never moves it.
- Main-window scenes are always dark.

## Cards

- Artwork on top; then name, status dot, one subtitle, secondary round buttons leading and the
  primary button trailing. Tapping the card runs the primary action.
- `cardSurface()`: ultra-thin material, `.cardFill`, a `.cardStroke` hairline; focus shows a
  `primaryFill` outline. On iPhone and iPad a card, row or tile is one focus stop for a
  controller or keyboard; the buttons inside are not.
- Loading, empty, error and real cards in a row are the same size.

## Sizes

Every length comes from `@Environment(\.dimensions)`.

- Space, corner radius and shadow are scales; gaps, corners and shadows take the nearest step.
- A size for one element is a named `Dimensions` property (`homeCardWidth`), shared or in the
  platform's `DimensionsOn<Platform>.swift`; a derived size is computed from others.
- Opacities, durations and ratios aren't lengths: they stay private to their type.
- Types without an environment (`Shape`, `NSView`) get lengths from the view that creates them.

## Loading, empty, error

- Content with a shape loads as a skeleton of that shape (`.cardFill` with a shimmer, still under
  Reduce Motion, read as "Loading"). A spinner only where there is no shape: connecting, a power
  command, waiting for sign-in.
- An empty or failed state is a title, at most one line of explanation and one action, the same
  size as its neighbours. A search with no results uses `ContentUnavailableView.search`.

## Words

- Short labels next to what they describe ("Connecting…"); one or two words on a button.
- Explanations only in Settings, one sentence each. A confirmation asks one question, no body.
- No marketing copy beyond the welcome screen.

## Streaming

- Black, always dark; while playing only the picture is permanent.
- Overlays are neutral in every palette: statistics top-leading; on the Mac a glass control bar
  near the bottom; on iPhone and iPad a glass menu handle at the top. When they show is in
  [product.md](product.md).
- Touch controls use Touch Controller's own look, in a layer above the picture and below menus,
  inside the safe area and clear of a fold.
- Waiting and end pages centre name, status and buttons; artwork is a background.

## Platforms

- **visionOS:** system glass and styles; the palette (Nebula) only replaces the accent.
- **tvOS:** the palette colours the sky and the accent; cards are system `.card` buttons with
  secondary actions in a context menu; focus scaling is never clipped.

## Motion

Under Reduce Motion: the sky is still, cards fade in without delay, hover lift and growth,
shimmer, dot pulse and the connecting ring stop. Presses still respond with short springs.
Previews skip entrance animations.

## Accessibility

- System controls and text styles, so Dynamic Type works; fixed sizes only for display text,
  artwork placeholders and round-button symbols.
- State is never colour alone.
- A card or row is one VoiceOver element labelled from its presentation ("<name>, <status>",
  "Play <game>"); the sign-in code reads character by character.
- Decorative layers (sky, dots, connecting ring) are hidden from VoiceOver.
