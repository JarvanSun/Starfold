# Views

A view lays out values it is given and forwards what the person does. A screen's `body` shows at
a glance how many sections it has and where its presentations come from. Each platform writes its
own views in its own idiom; they share ViewModels, presentation and the user interface pieces, never view code that
branches by platform.

## The body is the table of contents

`StarfoldMac/Features/Home/HomeView.swift`:

```swift
struct HomeView: View {
    @Environment(\.dimensions) private var dimensions

    let home: HomeViewModel
    let library: LibraryViewModel
    let onOpenCloudLibrary: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: dimensions.spaceXXLarge) {
                HomeCardRow(home: home, library: library, onOpenCloudLibrary: onOpenCloudLibrary)

                if !library.recentGames.isEmpty {
                    RecentGamesRow(
                        games: library.recentGames(limit: recentGameLimit),
                        onPlay: library.play(_:)
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.vertical, dimensions.spaceXLarge)
            .frame(maxWidth: .infinity)
            .animation(.smooth(duration: 0.45), value: library.recentGames)
        }
        .scrollIndicators(.hidden)
        .defaultScrollAnchor(.center)
        .refreshable { await home.refreshAccount() }
    }
}
```

The page reads only its ViewModels: playing a game is `LibraryViewModel.play(_:)`, playing a
console `HomeViewModel.play(_:)`, and what turns either into a stream is behind them
([view-models.md](view-models.md#intents-and-queries)).

- Each top-level section is a named view, separated by one blank line, named for what it shows
  (`HomeCardRow`, `RecentGamesRow`), never where it sits (`TopView`).
- A section receives the values and actions it needs, not the whole model, unless it needs
  bindings or observes many of its properties.
- Every section of a page is its own View in the feature's `Components/`
  (`StarfoldMac/Features/Home/Components/`) with its own preview
  (`GameHero`, `GameFacts`, `GameScreenshots`; `ShelfRow`, `AllGamesGrid`, `SortPicker`). A page's
  `body` is the list of its sections and nothing else, so the file shows how the page is built.
- `private` computed views are only for small details inside one component (a badge, a label, an
  icon with its background), never for a section.
- Closure properties are named for the event: `onOpenCloudLibrary`, `onPlay`, `onClose`, `onRetry`.

## Siblings

Views that sit side by side in a container (`VStack`, `HStack`, `ZStack`, `Group`, a `ViewBuilder`
closure) are separated by one blank line, whether each is one line or carries modifiers, so the
eye counts the views before reading them:

```swift
VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
    RoundedRectangle(cornerRadius: dimensions.cornerRadiusSmall)
        .fill(.white.opacity(0.10))
        .frame(width: dimensions.skeletonTitleWidth, height: dimensions.skeletonTitleHeight)

    HStack(spacing: dimensions.spaceLarge) {
        …
    }
}
```

A single child, the cases of a `switch` and the branches of an `if` have no blank line before
them.

## What a View may decide

Nothing. A View lays out what its ViewModel and the values it was given say, and forwards what the
person does as an intent. It never filters, sorts, maps or groups data, never picks one state out
of several, never derives a title, a list or a flag from model data, and never formats a value
itself — each of those is a ViewModel query or a presentation extension.

- State that changes what is shown — search text, the selected game, which placeholder applies, a
  sort, a confirmation's subject — lives in the ViewModel.
- A View keeps only state that is purely visual and dies with it: hover, focus, an entrance
  animation's progress, whether a sheet it owns is open.
- Closures a View receives start intents; they never contain decisions.

## State in the body

- Optional content is attached with `overlay(if:)` or a `switch` over the optional, never
  `if let` in a `body`.
- Mutually exclusive content is a `switch` over an enum the ViewModel answers with
  (`LibraryPlaceholder`, `ConsolesContent`, `ConsolePowerControl`); a view never derives one
  from several values itself.
- A `switch` in a view shows all its cases at a glance: each case is one line, or a few at most,
  that calls an extracted piece in the view's `private extension` or its own view type.
- No conditional expressions that pick strings, symbols, colours or actions inline: they come from
  a presentation extension or a private `switch`.
- No literal colours, strings or sizes outside their owners. Every spacing, padding, frame size,
  corner radius, line width and point size is read from `@Environment(\.dimensions)`
  ([user-interface.md](user-interface.md#spacing-and-sizes)); a view never writes a size number and
  never declares its own size properties or `…Dimensions` type.

## Platform idiom

| Platform | Navigation | Primary input | Notes |
|---|---|---|---|
| Mac | One main window (`MainWindowView`) with a `NavigationStack` of `HomeRoute`s; a separate stream window; a Settings window; a menu bar extra | Pointer and keyboard | Every stream control also has a menu command and shortcut |
| Vision Pro | `TabView` with `…HostView` roots; the stream window is pushed in place of the main window | Gaze and pinch, game controller | Glass and the system accent; controls in an ornament |
| Apple TV | `TabView` with `…HostView` roots; the stream is a full-screen cover | Siri Remote focus, game controller | System cards and colours; the stream menu is a system sheet |

- On Vision Pro and Apple TV each tab's root is a `…HostView` in `Navigation/`: it owns the tab's
  `NavigationStack` and its destinations, and hands the feature's main view the ViewModels it
  shows, with a loading view until they exist. A feature's pages never create the stack they are
  pushed on.
- On every platform `Navigation/SignInHostView` gives the welcome page and the Add Account sheet
  their `SignInViewModel`; the pages run it from their own `.task(id: signIn.attempt)`.
- Views that show the same thing on several platforms are written per platform, from the same
  ViewModel and presentation, and have the same name and path on each (`ConsoleCard`):
  `StarfoldMac/Features/Home/Components/ConsoleCard.swift` and
  `StarfoldTV/Features/Home/Components/ConsoleCard.swift`.
- No platform prefix: each target compiles only its own platform's folder, so `HomeView` names a
  different type in each.
- Loads run from `.task` / `.task(id:)` calling an `async` method of the model, so SwiftUI starts
  and cancels them ([view-models.md](view-models.md#async-work)). A button that reloads calls an intent.
- Views hold no `Task` they do not need to cancel themselves.
- Reduce Motion stops ambient motion (the sky, entrances, hover growth); a press still responds.

## Accessibility

The baseline is in [user-interface.md](user-interface.md). In a view:

- A card or row that reads as one thing is one element, with a label from the model's
  presentation.
- A symbol-only button has a text label.
- A status shown only as a coloured dot has words for VoiceOver.

Previews are in [testing.md](testing.md#previews).
