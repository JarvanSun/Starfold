# Views

A view lays out values it is given and forwards what the person does. Each platform writes its own
views; they share ViewModels, presentation and interface pieces, never view code that branches by
platform.

## The body is the table of contents

```swift
struct HomeView: View {
    @Environment(\.dimensions) private var dimensions

    let home: HomeViewModel
    let library: LibraryViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: dimensions.spaceXXLarge) {
                HomeCardRow(home: home, library: library)

                RecentGamesRow(
                    games: library.recentGames(limit: recentGameLimit),
                    onPlay: library.play(_:)
                )
            }
        }
        .refreshable { await home.refreshAccount() }
    }
}
```

- A page's `body` is the list of its sections and nothing else. Each section is its own View in
  the feature's `Components/` with its own preview, named for what it shows (`HomeCardRow`), never
  where it sits (`TopView`).
- A section receives the values and actions it needs, not the whole model, unless it needs
  bindings or observes many properties.
- `private` computed views are only for small details inside one component (a badge, a label),
  never a section.
- Closure properties are named for the event (`onPlay`, `onRetry`).
- Actions and content builders are written as closures, never passed by name (a method, an
  initializer or a closure property): `Button("retry") { onRetry() }`, `onPlay: { play() }`,
  `ForEach(games) { tile(for: $0) }`. Previews wrap every argument in a generic function, which
  breaks the conversion to SwiftUI's main-actor closure types. Forwarding a closure property to a
  child view's property of the same type (`onRetry: onRetry`) is fine.

## Siblings

Views side by side in a container (`VStack`, `HStack`, `ZStack`, `Group`, a `ViewBuilder`
closure) are separated by one blank line, whether one line or carrying modifiers:

```swift
VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
    RoundedRectangle(cornerRadius: dimensions.cornerRadiusSmall)
        .frame(width: dimensions.skeletonTitleWidth, height: dimensions.skeletonTitleHeight)

    HStack(spacing: dimensions.spaceLarge) { … }
}
```

A single child, `switch` cases and `if` branches have no blank line before them.

## What a View may decide

Nothing. A View never filters, sorts, maps or groups data, never picks one state out of several,
never derives a title, list or flag from model data, and never formats a value; each is a
ViewModel query or a presentation extension ([view-models.md](view-models.md#intents-and-queries)).

- State that changes what is shown (search text, selected game, placeholder, sort, a
  confirmation's subject) lives in the ViewModel.
- A View keeps only purely visual state that dies with it: hover, focus, entrance progress,
  whether a sheet it owns is open.
- Closures a View receives start intents; they never contain decisions.

## State in the body

- Optional content uses `overlay(if:)` or a `switch` over the optional, never `if let`.
- Mutually exclusive content is a `switch` over an enum the ViewModel answers with
  (`LibraryPlaceholder`, `ConsolesContent`); each case is a line or a few calling an extracted
  piece.
- No inline conditionals picking strings, symbols, colours or actions: they come from a
  presentation extension or a private `switch`.
- No literal colours, strings or sizes. Every spacing, padding, frame size, corner radius, line
  width and point size is read from `@Environment(\.dimensions)`
  ([user-interface.md](user-interface.md#spacing-and-sizes)); a view never declares its own size
  properties or `…Dimensions` type.

## Platform idiom

| Platform | Navigation | Primary input | Notes |
|---|---|---|---|
| Mac | One main window (`MainWindowView`) with a `NavigationStack` of `HomeRoute`s; a stream window; a Settings window; a menu bar extra | Pointer and keyboard | Every stream control also has a menu command and shortcut |
| Vision Pro | `TabView` with `…HostView` roots; the stream window replaces the main window | Gaze and pinch, game controller | Glass and the system accent; controls in an ornament |
| Apple TV | `TabView` with `…HostView` roots; the stream is a full-screen cover | Siri Remote focus, game controller | System cards and colours; the stream menu is a system sheet |
| iPhone, iPad | `TabView` (bottom on iPhone, top on iPad) with `…HostView` roots; the stream is a full-screen cover | Touch, game controller, keyboard on iPad | Layout follows size classes, never the device; touch controls are Apple Touch Controller over the picture |

- On Vision Pro and Apple TV each tab's root `…HostView` in `Navigation/` owns the tab's
  `NavigationStack` and destinations, and hands the feature's main view its ViewModels, with a
  loading view until they exist. Feature pages never create the stack they are pushed on.
- `Navigation/SignInHostView` gives the welcome page and the Add Account sheet their
  `SignInViewModel`; the pages run it from `.task(id: signIn.attempt)`.
- Views showing the same thing on several platforms are written per platform with the same name
  and path (`Features/Home/Components/ConsoleCard.swift`).
- Loads run from `.task` / `.task(id:)` ([view-models.md](view-models.md#async-work)); a reload
  button calls an intent. Views hold no `Task` they do not need to cancel themselves.

## Accessibility

Baseline in [user-interface.md](user-interface.md#accessibility). Previews are in
[testing.md](testing.md#previews).
