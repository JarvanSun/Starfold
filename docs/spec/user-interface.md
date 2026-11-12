# User Interface

Starfold looks like a game launcher, not a utility: a dark animated sky, large cards and, while
playing, nothing but the picture. Under that it is a native app on each platform: system
containers, controls, text styles, SF Symbols and navigation, with no hand-drawn system chrome.
The shared pieces live in `StarfoldShared/UserInterface/`; platform views use them by name, never raw values.

## Two layers of colour

| Layer | Type | Holds | Follows the palette |
|---|---|---|---|
| Brand | `Palette` (`@Environment(\.palette)`) | Sky, primary button, accent, dark surfaces | Yes |
| Semantic | `Color` extensions (`.online`, `.standby`, `.attention`, `.cardFill`, `.cardStroke`) | Status colours, card fill and stroke | No |

- Nothing else defines a colour. Text uses the system's hierarchy (`.primary`, `.secondary`), and
  errors use the system red.
- The palette reaches a scene through `.appPalette()`, which sets the environment value and, except
  on Apple TV, the scene's tint to the palette's accent.

### Palettes

The player picks one in Settings (`PalettePicker`, labelled Color, each option showing its button
colour). It applies at once, also during a stream; an unknown stored value reads as Nebula.

| Palette | Sky (top → bottom, glow) | Primary button (fill / label) | Accent |
|---|---|---|---|
| Nebula (default, the icon's colour) | `#0A0A1C` → `#1B1442`, violet glow | `#6652E8` / white | `#A99FFF` |
| Aurora | `#05141A` → `#0A2229`, green-teal glow | `#0A8470` / white | `#3DDBB0` |
| Sunrise (the original look) | Night blue, warm glow, bright amber-coral ribbons | Amber `#FFB042` → coral `#FF684B` / black at 85 % | Amber |

- Every palette's primary label meets 4.5:1 against every colour of its fill; a unit test checks it.
- Gradients and glow belong to Sunrise only: its button is a gradient with a coral glow. Every
  other palette has a solid button with a plain drop shadow.
- A new palette adds a `PaletteID` case with all its values; it never changes the semantic layer.

### Where brand colour may go

| Palette value | Used for |
|---|---|
| `sky` | The animated background, and nothing else |
| `primaryFill`, `primaryLabelColor` | The one primary action of a card or screen; symbols of empty and error states; the keyboard-focus outline of a card |
| `accent` (the tint) | System controls, links, highlights, the connecting ring |
| `primaryTint` | A single colour for prominent system buttons, badges and the favourite heart |
| `night`, `nightRaised` | Artwork placeholders and the dim layer over blurred game art |

Brand colour never marks a state, never colours text in a list, and never appears in the stream's
overlays except the selected state of a control.

### Semantic colours

| Colour | Value | Means |
|---|---|---|
| `online` | `#4FD97E` | Console on, cloud gaming available, latency under 50 ms, signed in |
| `standby` | System grey | Console asleep, free-to-play only; at 40 % opacity, console off |
| `attention` | `#FFC742` | Needs a look: latency 50–90 ms, a failed stream, a sign-in error |
| System red | — | Latency over 90 ms, destructive actions |
| `cardFill`, `cardStroke` | White at 6 % / 10 % | Card surfaces and placeholders over the sky |

A status colour always comes with words: visible text, or the VoiceOver label of the dot.

## Buttons

| Style | Looks like | Use |
|---|---|---|
| `.primary`, `.primaryLarge`, `PrimaryButtonStyle(compact:)` | Palette-filled capsule; compact matches the 34-pt round buttons | The one main action: Play, Browse Games, Open Link, Try Again |
| `.circleIcon` | 34-pt circle, white at 12 % (20 % under the pointer), icon only | Secondary card actions: settings, power |
| `TileButtonStyle` | No chrome; lifts and casts a deeper shadow under the pointer | Game artwork tiles |
| System `.bordered`, `.borderedProminent`, `.glass`, `.card` | The system's | Everything else, and every button on visionOS and tvOS |

- The primary style lightens and grows 3 % under the pointer, shrinks to 96 % when pressed, and is
  disabled at 40 % opacity, desaturated.
- An icon-only button always has a label for VoiceOver and, on the Mac, a tooltip; a tooltip names
  the command's shortcut when it has one.

## The animated sky

- `SkyBackground` draws the palette's sky with a Metal shader: a vertical gradient, one glow low on
  the right and three slow light ribbons, at up to 30 frames per second.
- It sits behind the home screen, the library and game pages, the welcome screen and the stream
  window's waiting page for a console, and behind the Apple TV tabs. It is hidden from VoiceOver.
- It freezes on one fixed frame with Reduce Motion, and on the Mac while its window is inactive.
- Every main-window scene is dark (`.preferredColorScheme(.dark)`); there is no light appearance.

## Cards

- A card is artwork on top and an information area below: name, a status dot, one line of subtitle,
  secondary round buttons on the leading side and the primary button on the trailing side. The whole
  card runs the primary action.
- `cardSurface()` is the surface: ultra-thin material, `.cardFill`, a 1-pt `.cardStroke`
  border; with keyboard focus the border becomes a 2-pt `primaryFill` outline. Cards are material,
  not Liquid Glass.

| Platform | Size | Corner radius | Artwork |
|---|---|---|---|
| Mac | 300 × 356 pt | `cornerRadiusXLarge` (24) | 220 pt tall |
| Vision Pro | 400 × 360 pt, regular material, highlight hover effect | `cornerRadiusXXLarge` (32) | 16:9 |
| Apple TV | A third of the screen width, at least 360 pt; system `.card` button | `cornerRadiusXLarge` (24) | 16:9 |

- Loading, empty, error and real cards in one row have the same size, so nothing jumps when one
  replaces another.
- On the Mac a card lifts `spaceSmall` (8 pt) under the pointer and its artwork scales 4 %; cards enter with a
  staggered spring, 0.08 s apart.
- The cloud card fans three real covers from the library; a console card shows its cover (see
  Console snapshots in the product spec). Over artwork, text is white on a dark layer whatever the
  palette.

## Spacing and sizes

Every length the interface uses comes from one value, `Dimensions`, read anywhere in a view with
`@Environment(\.dimensions) private var dimensions`:

```swift
HStack(spacing: dimensions.spaceXLarge) {
    …
}
.padding(.horizontal, dimensions.spaceXXXLarge)
.clipShape(.rect(cornerRadius: dimensions.cornerRadiusXLarge))
```

`StarfoldShared/UserInterface/Dimensions/Dimensions.swift` defines three scales; a length that is a gap, a
corner or a shadow always takes a step from its scale, never a value of its own:

| Scale | Steps |
|---|---|
| Spacing (gaps, padding, margins) | `spaceXXSmall` 2, `spaceXSmall` 4, `spaceSmall` 8, `spaceMedium` 12, `spaceLarge` 16, `spaceXLarge` 24, `spaceXXLarge` 32, `spaceXXXLarge` 48, `spaceHuge` 64 |
| Corner radius | `cornerRadiusSmall` 8, `cornerRadiusMedium` 12, `cornerRadiusLarge` 16, `cornerRadiusXLarge` 24, `cornerRadiusXXLarge` 32 |
| Shadow | `shadowRadiusSmall` 6, `shadowRadiusMedium` 14, `shadowRadiusLarge` 30, with `shadowOffsetSmall` 3, `shadowOffsetMedium` 8, `shadowOffsetLarge` 18 |

- A value between two steps takes the nearer step; the design is the scale, not the number a view
  once had.
- What the scales can't express is a size that belongs to one element: a card's width, a window,
  a symbol's point size, an artwork's height. Those are named properties of `Dimensions`, named for
  the element (`homeCardWidth`), never for a value or a gap. Sizes every platform uses (the main
  and stream windows) are in the shared file; a platform's own are an `extension Dimensions` in
  its `UserInterface/Dimensions/DimensionsOn<Platform>.swift`.
- A size that follows from others is computed from them (`consoleCardArtworkHeight` is
  `consoleCardWidth * 9 / 16`).
- Zero is written as `0`. Opacities, durations, counts, ratios and scale factors are not lengths:
  they stay private properties of the type that uses them.
- A `#Preview` may give the canvas a literal frame.
- A type that has no environment (a `Shape`, a `Layout`, a model, an `NSView`) receives the lengths
  it needs from the view that creates it.

## Loading

- Content that has a shape loads as a skeleton of that shape, never a spinner: `SkeletonCard` on the
  home screen, `LibrarySkeleton` in the library, `SkeletonCard` and `LoadingView` on Apple TV,
  card-sized material placeholders on Vision Pro, and the sign-in panel's own outline.
- Skeletons are `.cardFill` shapes with a soft moving highlight (`shimmering()`, still under
  Reduce Motion; Apple TV's `LoadingView` is still), and read "Loading" to VoiceOver.
- A spinner is allowed only where no content shape exists yet: connecting to a stream, a power
  command in flight, waiting for sign-in, and on Vision Pro restoring the account and loading the
  library.
- The saved library is shown first; a refresh never blanks content already on screen.

## Empty and error states

- Every empty or failed state is a title, at most one line of explanation and one action that gets
  the player moving: Refresh, Try Again, Get a New Code, Check Again.
- On the Mac it is a `MessageCard` the size of the cards around it, its symbol in `primaryFill`;
  Vision Pro and Apple TV use their own `MessageView`. A search without results uses the
  system's `ContentUnavailableView.search`.
- Host and service errors are first translated into the step that fixes them; the raw text is shown
  only when nothing matches.

## Words

- Flow screens use short labels next to what they describe: "Scan with your phone", "Connecting…",
  "Connection failed".
- Explanations live only in Settings, one sentence per setting, saying what it does, not how.
- Buttons are one or two words. A confirmation asks one question ("Sign out of <gamertag>?") with
  no body.
- No marketing copy inside the app beyond the welcome screen's headline and three short features.

## Streaming comes first

- The stream window is black and always dark. While playing, only the picture is permanent.
- Overlays on the picture are neutral and dark in every palette: the statistics in the top-leading
  corner (glass, or material on Apple TV) and, on the Mac, the control bar centred 24 pt above the
  bottom edge, icon-only glass buttons in a `GlassEffectContainer`.
- **Mac.** The control bar appears when the pointer moves (and when the picture starts) and fades
  out, with the pointer, after 3 seconds without movement. Every control-bar command is also in the
  Stream menu.
- **Vision Pro.** The controls are an ornament hanging below the window, always visible while
  streaming: a tap to summon them and a timer to hide them only got in the way in the headset.
- **Apple TV.** Play/Pause opens a system sheet sized to its rows; the player closes it, it never
  hides on a timer.
- The waiting and end pages centre the name, status and buttons in the window, whatever the artwork
  behind them; the artwork is a background, not a sibling in the layout.

## Platform exceptions

- **Mac Settings window.** System neutral in every palette: macOS draws its selected toolbar tab from
  the asset accent, which can't follow a palette, so its controls don't either. The menu bar extra
  is a standard system menu.
- **visionOS.** No palette at all: system glass, materials, the system accent and system button
  styles; there is no palette setting. The semantic status colours still apply.
- **tvOS.** The palette only colours the sky. Text, buttons and focus use system colours; the palette
  sets no tint. Cards are system `.card` buttons on `.cardFill`; secondary actions go in a
  context menu. Focus scaling has room to grow and is never clipped by its scroll view.

## Motion

| Motion | With Reduce Motion |
|---|---|
| Sky ribbons and glow | One still frame |
| Card entrance (fade, rise, scale, stagger) | Fade only, no delay |
| Card lift on hover | None |
| Skeleton highlight | None |
| Status dot pulse while a console is on | A still dot |
| Connecting ring | A still ring |

- Previews set `skipsEntranceAnimations` to show the final state.
- Presses and hovers answer with short springs (a 96–97 % press, a few percent of lift); they are
  feedback to the player's own action, not ambient motion.

## Accessibility

- System controls and text styles throughout, so Dynamic Type works. The only fixed sizes are
  display text on the stream's waiting page, artwork placeholders and the round buttons' symbols.
- Every icon-only button has a label; on the Mac it also has a tooltip.
- State is never colour alone: a console's dot carries its power state for VoiceOver, latency shows
  its number, failures show words.
- A home card is one element read as "<name>, <status>"; a recent game reads "Play <game>"; the sign-in
  code reads character by character.
- Decorative layers (the sky, status dots, the connecting ring) are hidden from VoiceOver.
- Reduce Motion is honoured as in the table above.
