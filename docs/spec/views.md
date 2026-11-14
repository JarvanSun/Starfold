# Views

A View shows the values it is given and passes on what the person does. Each platform writes its
own views; they share ViewModels, presentation and interface pieces, never view code that branches
by platform.

## Structure

```swift
struct HomeView: View {
    @Environment(\.dimensions) private var dimensions

    let homeViewModel: HomeViewModel
    let libraryViewModel: LibraryViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: dimensions.spaceXXLarge) {
                HomeCardRow(homeViewModel: homeViewModel, libraryViewModel: libraryViewModel)

                RecentGamesRow(
                    games: libraryViewModel.recentGames(limit: recentGameLimit),
                    onPlay: { libraryViewModel.play($0) }
                )
            }
        }
        .refreshable { await homeViewModel.refreshAccount() }
    }
}
```

- A page's `body` reads as a list of its sections.
- A section gets its own file in `Components/`, with a preview, when it has its own inputs or
  state, is reused, or would make `body` hard to read; otherwise it stays a private computed view.
  It is named for what it shows (`HomeCardRow`), not where it sits.
- A section takes the values and actions it needs, not the whole ViewModel, unless it binds or
  reads many properties.
- Pass actions as closures (`onPlay: { play() }`, `Button("retry") { onRetry() }`), not by name:
  previews break the conversion to SwiftUI's main-actor closure types. Forwarding a closure
  property as is (`onRetry: onRetry`) is fine.
- Sibling views in a container are separated by one blank line.

## What a View decides

Nothing. It never filters, sorts, groups or formats data, picks one state among several, or
derives a title or flag from model data; the ViewModel or a presentation extension answers.

- State that changes what is shown lives in the ViewModel. A View keeps only visual state that
  dies with it: hover, focus, an animation's progress, whether its own sheet is open.
- Optional content uses `if let`; content over other content uses `overlay(if:)`.
- Mutually exclusive content is a `switch` over an enum the ViewModel provides.
- A two-way choice on one `Bool` may be a ternary (`isFavorite ? "heart.fill" : "heart"`); more
  choices, or ones that read model data, come from a presentation extension.
- No literal colours, strings or sizes: lengths come from `@Environment(\.dimensions)`
  ([user-interface.md](user-interface.md#sizes)).

## Platforms

| Platform | Navigation | Input |
|---|---|---|
| Mac | Main window with a `NavigationStack` of `HomeRoute`s; stream window; Settings; menu bar extra. Every stream control has a menu command and shortcut | Pointer, keyboard |
| Vision Pro | `TabView` of `…HostView`s; the stream window replaces the main window; controls in an ornament | Gaze and pinch, controller |
| Apple TV | `TabView` of `…HostView`s; the stream is a full-screen cover; system cards and sheets | Siri Remote, controller |
| iPhone, iPad | `TabView` of `…HostView`s; the stream is a full-screen cover; layout follows size classes | Touch, controller, keyboard |

- A tab's `…HostView` in `Navigation/` owns its `NavigationStack` and hands pages their
  ViewModels; pages never create the stack they are pushed on.
- A view shown on several platforms has the same name and path on each.
- Loads run from `.task` ([view-models.md](view-models.md#async-work)); a reload button calls an
  intent.

Accessibility: [user-interface.md](user-interface.md#accessibility). Previews:
[testing.md](testing.md#previews).
