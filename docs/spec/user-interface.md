# User Interface

A dark animated sky, large cards and, while playing, only the picture; underneath, native system
containers, controls, text styles, SF Symbols and navigation, with no hand-drawn system chrome.
Shared pieces live in `StarfoldShared/UserInterface/`; views use them by name, never raw values.

## Colour

| Layer | Type | Holds | Follows the palette |
|---|---|---|---|
| Brand | `Palette` (`@Environment(\.palette)`) | Sky, primary button, accent, dark surfaces | Yes |
| Semantic | `Color` extensions (`.online`, `.cardFill`, …) | Status colours, card fill and stroke | No |

- Nothing else defines a colour. Text uses the system hierarchy (`.primary`, `.secondary`); errors
  use the system red.
- `.appPalette()` sets the palette in the environment. On every platform the palette's accent
  replaces the system accent only where the system would use its accent (tab and list selection,
  switches, links, plain buttons, sliders): iPhone, iPad, Apple TV and Vision Pro set it as the
  window's tint (`windowTint()`), the Mac as its main and stream windows' tint (`paletteTint()`;
  the Mac's own accent asset stays grey, see Platforms). Controls the
  system draws in neutral colours (menu values, Form text, glass buttons) stay neutral; a SwiftUI
  `.tint` over a whole iOS scene would recolour them too.

### Palettes

Picked in Settings (`PalettePicker`, labelled Color); applies at once, also mid-stream; an unknown
stored value reads as Nebula.

| Palette | Sky (top → bottom, glow) | Primary button (fill / label) | Accent |
|---|---|---|---|
| Nebula (default) | `#0A0A1C` → `#1B1442`, violet glow | `#6652E8` / white | `#A99FFF` |
| Aurora | `#05141A` → `#0A2229`, green-teal glow | `#0A8470` / white | `#3DDBB0` |
| Sunrise | Night blue, warm glow, bright amber-coral ribbons | Amber `#FFB042` → coral `#FF684B` / black at 85 % | Amber |

- Every primary label meets 4.5:1 against every colour of its fill (unit-tested).
- Only Sunrise has a gradient button with a coral glow; the others are solid with a plain drop
  shadow.
- A new palette adds a `PaletteID` case with all its values and never changes the semantic layer.

| Palette value | Used for |
|---|---|
| `sky` | The animated background only |
| `primaryFill`, `primaryLabelColor` | The one primary action of a card or screen; symbols of empty and error states; a card's keyboard-focus outline |
| `accent` (the window tint) | Where the system would use its accent, highlights, the connecting ring, the touch editor's selection ring |
| `primaryTint` | Prominent buttons, badges, the favourite heart |
| `night`, `nightRaised` | Artwork placeholders, the dim layer over blurred game art |

Brand colour never marks a state, never colours list text, and never appears in stream overlays
except a control's selected state.

| Semantic colour | Value | Means |
|---|---|---|
| `online` | `#4FD97E` | Console on, cloud available, latency < 50 ms, signed in |
| `standby` | System grey | Console asleep, free-to-play only; at 40 % opacity, console off |
| `attention` | `#FFC742` | Latency 50–90 ms, a failed stream, a sign-in error |
| System red | — | Latency > 90 ms, destructive actions |
| `cardFill`, `cardStroke` | White at 6 % / 10 % | Card surfaces and placeholders over the sky |

A status colour always comes with words: visible text or the dot's VoiceOver label.

## Buttons

| Style | Looks like | Use |
|---|---|---|
| `.primary`, `.primaryLarge`, `PrimaryButtonStyle(compact:)` | Palette-filled capsule; compact matches the 34-pt round buttons | The one main action |
| `.circleIcon` | 34-pt circle, white at 12 % (20 % hovered), icon only | Secondary card actions |
| `TileButtonStyle` | No chrome; lifts with a deeper shadow under the pointer | Game artwork tiles |
| System `.bordered`, `.borderedProminent`, `.glass`, `.card` | The system's | Everything else, and every button on visionOS and tvOS |

- The primary style lightens and grows 3 % on hover, shrinks to 96 % pressed, and is disabled at
  40 % opacity, desaturated.
- An icon-only button has a VoiceOver label and, on the Mac, a tooltip naming its shortcut if any.

## The animated sky

- `SkyBackground` is a Metal shader: vertical gradient, one glow low right, three slow ribbons, up
  to 30 fps. It is hidden from VoiceOver.
- It sits behind home, library and game pages, the welcome screen, a console stream's waiting
  page, and the Apple TV tabs.
- It freezes on one frame under Reduce Motion, and on the Mac while its window is inactive.
- On iPhone and iPad it is drawn at the window's size from the top of the page, so the keyboard
  never resizes it or moves its ribbons.
- Every main-window scene is dark (`.preferredColorScheme(.dark)`).

## Cards

- Artwork on top; below, name, status dot, one subtitle line, secondary round buttons leading and
  the primary button trailing. The whole card runs the primary action.
- `cardSurface()`: ultra-thin material, `.cardFill`, 1-pt `.cardStroke` border, a 2-pt
  `primaryFill` outline with keyboard focus. Material, not Liquid Glass.
- On iPhone and iPad every card, row and game tile is one focus stop for a game controller or a
  keyboard: focus shows the same 2-pt `primaryFill` outline (on a tile, around its artwork, which
  also lifts); the buttons inside a card are never focused on their own.

| Platform | Size | Corner radius | Artwork |
|---|---|---|---|
| Mac | 300 × 356 pt | `cornerRadiusXLarge` | 220 pt tall |
| Vision Pro | 400 × 360 pt, regular material, highlight hover effect | `cornerRadiusXXLarge` | 16:9 |
| Apple TV | A third of the screen width, at least 360 pt; system `.card` button | `cornerRadiusXLarge` | 16:9 |
| iPhone, iPad | Compact width: the readable width, paged sideways; regular width: the Mac's 300 × 356 pt | `cornerRadiusXLarge` | 16:9 |

- Loading, empty, error and real cards in one row have the same size.
- On the Mac a card lifts `spaceSmall` on hover and its artwork scales 4 %; cards enter with a
  staggered spring, 0.08 s apart.
- The cloud card fans three real covers; a console card shows its cover. Text over artwork is
  white on a dark layer.

## Spacing and sizes

Every length comes from `Dimensions`, read with `@Environment(\.dimensions) private var dimensions`:

```swift
HStack(spacing: dimensions.spaceXLarge) { … }
    .clipShape(.rect(cornerRadius: dimensions.cornerRadiusXLarge))
```

| Scale (`Dimensions.swift`) | Steps |
|---|---|
| Spacing | `spaceXXSmall` 2, `spaceXSmall` 4, `spaceSmall` 8, `spaceMedium` 12, `spaceLarge` 16, `spaceXLarge` 24, `spaceXXLarge` 32, `spaceXXXLarge` 48, `spaceHuge` 64 |
| Corner radius | `cornerRadiusSmall` 8, `cornerRadiusMedium` 12, `cornerRadiusLarge` 16, `cornerRadiusXLarge` 24, `cornerRadiusXXLarge` 32 |
| Shadow | `shadowRadiusSmall` 6, `shadowRadiusMedium` 14, `shadowRadiusLarge` 30, with `shadowOffsetSmall` 3, `shadowOffsetMedium` 8, `shadowOffsetLarge` 18 |

- A gap, corner or shadow always takes a step from its scale; a value between steps takes the
  nearer one.
- A size belonging to one element (card width, window, symbol point size, artwork height) is a
  named `Dimensions` property, named for the element (`homeCardWidth`). Shared sizes are in the
  shared file; a platform's own are an `extension Dimensions` in its
  `UserInterface/Dimensions/DimensionsOn<Platform>.swift`.
- A size that follows from others is computed (`consoleCardWidth * 9 / 16`).
- Zero is `0`. Opacities, durations, counts, ratios and scale factors are not lengths: they stay
  private properties of their type.
- A `#Preview` may give the canvas a literal frame.
- A type without environment (`Shape`, `Layout`, model, `NSView`) receives its lengths from the
  view that creates it.

## Loading, empty and error

- Content with a shape loads as a skeleton of that shape, never a spinner (`SkeletonCard`,
  `LibrarySkeleton`, Apple TV's `LoadingView`, Vision Pro's card-sized placeholders, the sign-in
  panel's outline). Skeletons are `.cardFill` shapes with `shimmering()` (still under Reduce Motion
  and on Apple TV) and read "Loading" to VoiceOver.
- A spinner only where no content shape exists: connecting to a stream, a power command in flight,
  waiting for sign-in, and on Vision Pro restoring the account and loading the library.
- A refresh never blanks content already on screen.
- An empty or failed state is a title, at most one line of explanation and one action. On the Mac
  it is a `MessageCard` the size of its neighbours, symbol in `primaryFill`; Vision Pro and Apple
  TV use `MessageView`; a search without results uses `ContentUnavailableView.search`.

## Words

- Flow screens use short labels next to what they describe ("Connecting…").
- Explanations live only in Settings, one sentence per setting, saying what it does.
- Buttons are one or two words. A confirmation asks one question with no body.
- No marketing copy beyond the welcome screen's headline and three short features.

## Streaming

- The stream window is black and always dark; while playing only the picture is permanent.
- Overlays are neutral and dark in every palette: statistics top-leading (glass, or material on
  Apple TV) and, on the Mac, the control bar centred 24 pt above the bottom, icon-only glass buttons
  in a `GlassEffectContainer`. When controls show and hide is in [product.md](product.md).
- On iPhone and iPad the stream menu opens from a glass handle centred at the top, and touch
  controls use Touch Controller's system contents, never the palette. They draw in their own
  layer above the picture and below the menu and dialogs, inside the safe area and clear of an
  active fold.
- The waiting and end pages centre name, status and buttons in the window; the artwork is a
  background, not a layout sibling.

## Platform exceptions

- **Mac:** the app's accent colour asset is a neutral grey, so what AppKit draws (alerts, focus
  rings, the Settings window, which takes no palette tint) stays neutral in every palette, as in
  1.0; the main and stream windows take the palette accent. The menu bar extra is a standard menu.
- **visionOS:** system glass, materials and button styles; the palette (Nebula, as Vision Pro has
  no colour picker) only replaces the system accent. Semantic status colours still apply.
- **tvOS:** the palette colours the sky and replaces the system accent; text, buttons and focus
  otherwise use system colours. Cards are system `.card` buttons on `.cardFill`, secondary actions in a context menu.
  Focus scaling is never clipped by its scroll view.

## Motion

| Motion | With Reduce Motion |
|---|---|
| Sky ribbons and glow | One still frame |
| Card entrance (fade, rise, scale, stagger) | Fade only, no delay |
| Card lift on hover, primary button hover growth | None |
| Skeleton highlight | None |
| Status dot pulse while a console is on | A still dot |
| Connecting ring | A still ring |

- Presses still respond under Reduce Motion: short springs (96–97 % press, a few percent of lift).
- Previews set `skipsEntranceAnimations` to show the final state.

## Accessibility

- System controls and text styles throughout, so Dynamic Type works. The only fixed sizes are the
  waiting page's display text, artwork placeholders and the round buttons' symbols.
- State is never colour alone: the dot carries the power state for VoiceOver, latency shows its
  number, failures show words.
- A card or row that reads as one thing is one element with a label from the model's presentation:
  a home card reads "<name>, <status>", a recent game "Play <game>"; the sign-in code reads
  character by character.
- Decorative layers (sky, status dots, connecting ring) are hidden from VoiceOver.
