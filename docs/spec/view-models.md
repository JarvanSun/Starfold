# ViewModels

A View lays out values and forwards what the person does; its ViewModel holds the state and every
decision. ViewModels are shared by all platforms, one per feature, in
`StarfoldShared/Features/<Feature>/`.

## Ownership and services

- `AppViewModel` lives for the app, one per app, in the environment. It creates the per-account
  ViewModels (switching accounts replaces them), the per-stream one (a restart replaces it) and
  each `SignInViewModel`.
- A feature's View never creates a ViewModel: `Navigation/` hands it one.
- A ViewModel reaches the outside world only through services it is given: protocols in
  `StarfoldShared/Services/`, each with a `Live…` implementation beside it. Live services hold
  protocol quirks; ViewModels hold state, order and saved snapshots.
- Services throw XboxKit's errors; a ViewModel turns `XboxAccountError.signInRequired` into
  `onSignInRequired`.
- A ViewModel that needs the app sees only a narrow protocol `AppViewModel` conforms to
  (`SigningIn`, `SessionControlling`), so tests give a stub.
- Storage is plain types given in (`Preferences`, `FavoritesStore`, `LibraryCache`).
- `AppDependencies` is the composition root: it builds the live services once and hands them to
  `AppViewModel`. No ViewModel has a preview-only or debug-only entry point.
- A screen never forwards a setting: the ViewModel that needs it applies it when `Preferences`
  changes (`StreamViewModel` computes `StreamPlaybackSettings` from them).

## Shape

- `@Observable public final class <Feature>ViewModel` at the top of its feature folder, with
  `Model/` and `Presentation/` beside it.
- `public` on what the apps and `Preview Content/` use (initializer, state and queries a View
  reads, intents a View calls); `internal` for the package and its tests; everything else
  `private`.
- Imports Foundation, Observation, XboxKit and StreamKit as needed; never SwiftUI, AppKit, UIKit
  or RealityKit; never reads the environment; no `#if os(…)`, no `#if DEBUG`.
- Its strings are in StarfoldShared's catalog ([localization.md](localization.md)).
- Every dependency is an `init` parameter stored as `private let`; no default arguments holding
  services or data.
- Platform differences arrive as values (`StreamPlatform`, `PictureCapabilities`).

## State

- Stored state is `private(set) var` (`public private(set)` when a View reads it). The only
  writable `var`s are values a View binds to (`isSignInExpired`, `powerProblem`, a setting).
- What something is doing is one enum (`SessionState`, `LoadState`: `idle`, `loading`, `loaded`,
  `failed`), never a set of booleans and optionals.
- Lists a View renders are derived (`shelves`, `visibleGames`), never a second stored copy.
- `@ObservationIgnored` appears only where the compiler requires it (a property wrapper, a
  `lazy var`) or where a value is deliberately kept from refreshing Views, with the reason in
  [decisions.md](decisions.md).

## Intents and queries

- Every user action is one method named for what the person does (`play(_:)`,
  `switchAccount(to:)`, `togglePower(of:)`). An intent guards its precondition, changes state,
  then starts work.
- The View asks; it never computes ([views.md](views.md#what-a-view-may-decide)). Every page has a
  ViewModel, including a page reached from another
  (`LibraryViewModel.makeGameDetailViewModel(for:)`). A question about an element is a method
  (`cover(for:)`), about the whole a property (`isStreaming`).
- An action that needs the app is still an intent of the page's ViewModel, calling a closure
  `AppViewModel` sets: `play(_:)` calls `onPlay` with the `StreamTarget`, `refreshAccount()` calls
  `onRefreshAccount`; `GameDetailViewModel.play()` goes through its library. `AppViewModel`
  starts the stream unless the platform set `onPlayRequest` (Apple TV's `StreamPresenter`).

## Async work

- Work a screen owns runs from the View's `.task` / `.task(id:)` as an `async` ViewModel method
  (`refresh()`, `SignInViewModel.run()`), so SwiftUI cancels it.
- Work that outlives a View is a `Task` the ViewModel stores and cancels (the account's initial
  load, the console refresh, a stream's update loop).
- Loads that run together use `async let` in the ViewModel.
- Cancellation is checked after each `await`; a cancelled load changes nothing.
- Old content stays visible during a refresh; the saved snapshot shows until the first refresh.

## Previews

`PreviewObjectPool` builds real ViewModels on preview services that answer at once (`loaded`),
never (`loading`) or fail (`failed`); the View's own `.task` does the rest
([swift-style.md](swift-style.md#preview-data)). A stream preview never shows a first frame.
