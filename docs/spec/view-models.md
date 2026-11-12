# ViewModels

A View lays out values and forwards what the person does; its ViewModel holds the state and every
decision. ViewModels are shared by all platforms, one per feature, in
`StarfoldShared/Features/<Feature>/`.

## The ViewModels

| ViewModel | Lives | Owns |
|---|---|---|
| `AppViewModel` | App lifetime; one per app, in the environment | Who is signed in, the accounts, the profile, the account's `HomeViewModel` and `LibraryViewModel`, the current `StreamViewModel` and each request to show it |
| `SignInViewModel` | One sign-in screen | The device code and its renewal, retrying, the panel's step, when the sheet closes, the welcome features |
| `HomeViewModel` | One signed-in account | Consoles, `consolesContent`, each console's status, cover and power control, playing a console, the power problem |
| `LibraryViewModel` | One signed-in account | Cloud games, recent, curated rows, favourites, search text and results, sort, shelves, the placeholder |
| `GameDetailViewModel` | One game's page | The game's artwork, inputs and facts ready to show, favourite, playing it |
| `SettingsViewModel` | App lifetime | Settings and their choices, controllers, accounts to switch to, signing out, restarting a stream |
| `StreamViewModel` | One stream | Phase, statistics, host dialogs, the renderer, input wiring |

- `AppViewModel` creates the per-account ViewModels (switching accounts replaces them), the
  per-stream one (a restart replaces it) and each `SignInViewModel` (`makeSignInViewModel()`).
- A feature's View never creates a ViewModel: `Navigation/` hands it one. `SignInHostView` asks
  for a `SignInViewModel` when its screen appears and keeps it while shown.

## Services

A ViewModel reaches the outside world only through services it is given: protocols in
`StarfoldShared/Services/`, each with a `Live…` implementation beside it.

```swift
public protocol AccountService {
    func restoreAccounts() async -> [SignedInAccount]
    func beginSignIn() async throws -> DeviceCodePrompt
    func completeSignIn(
        _ prompt: DeviceCodePrompt,
        onAuthorized: @escaping @MainActor () -> Void
    ) async throws -> SignedInAccount
    func profile(of account: SignedInAccount) async throws -> XboxProfile
    func signOut(_ account: SignedInAccount) throws
}

public protocol ConsoleService {
    func consoles() async throws -> [Console]
    func activity() async throws -> ConsoleActivity?
    func send(_ command: XboxLiveClient.PowerCommand, to consoleID: String) async throws
}

public protocol CloudLibraryService {
    func library() async throws -> CloudLibrary
}

public protocol StreamService {
    func connect(to target: StreamTarget, options: StreamOptions) async throws -> StreamConnection
    func setDirectStereo(_ isEnabled: Bool)
}
```

- `SignedInAccount` is an account's `AccountSummary` (xuid, gamertag) and its `ConsoleService`,
  `CloudLibraryService` and `StreamService`; it holds no token, so previews and tests build one
  from made-up values. `AppViewModel` keeps them by xuid.
- Services throw XboxKit's errors; a ViewModel turns `XboxAccountError.signInRequired` into
  `onSignInRequired`, which `AppViewModel` sets to raise `isSignInExpired`.
- `StreamService.connect` answers with a `StreamConnection` (`updates`, `start(sink:)`,
  `stop(reason:)`, `setGamepad`, `pressGuide()`, `requestKeyframe()`, `answerDialog`,
  `answerKeyboard`), backed by StreamKit's `StreamController`. `StreamViewModel.start()` connects
  in a `Task` it owns and reads updates until the stream ends.
- `StreamViewModel` answers every question its screens ask (`status`, `isShowingControls`,
  `statisticsReadout`, `canOpenMenu`, `needsController`, …) and applies picture, buffer and sound
  settings itself whenever `Preferences` changes, so no screen forwards a setting. What to apply
  is `StreamPlaybackSettings`, a value computed from `Preferences` and `PictureCapabilities`.
  `tryAgain()` asks `AppViewModel` for a new stream through `onRestart`; closing stays with
  `Navigation/`, which owns the window or cover.
- The console's system dialogs are `StreamViewModel.dialogs`, a `SystemDialogsViewModel` it
  creates and feeds from the connection's updates: the queue, the presented dialog, the drafted
  text and the answers. `SystemDialogView` talks to it, not to the stream.
- Live services hold protocol quirks (SmartGlass fallback, cloud access, catalogue joins);
  ViewModels hold state, order (by name) and saved snapshots: each per-account ViewModel restores
  and saves its part through `LibraryCache` (`HomeSnapshot`, `LibrarySnapshot`).
- `SettingsViewModel` exposes each setting as a bindable property backed by `Preferences`, the
  choices each picker offers, what the platform allows (`canToneMapHDR`, from the
  `PictureCapabilities` passed in), and what needs the app as intents and queries
  (`switchAccount(to:)`, `signOut()`, `needsStreamRestart`). Which sections exist is the
  platform's `SettingsView`.
- A ViewModel that needs the app sees only a narrow protocol `AppViewModel` conforms to:
  `SigningIn` for `SignInViewModel`, `SessionControlling` for `SettingsViewModel`. Tests give a
  stub.
- Storage is plain types given in: `Preferences` (`UserDefaults`), `FavoritesStore`,
  `LibraryCache`. Services, storage and their signature values are `public` where an app or a
  preview builds or reads them.
- `AppDependencies` (`StarfoldShared/App/`) is the composition root: it builds the live services
  once and hands them to `AppViewModel`. No ViewModel has a preview-only or debug-only entry point.

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
  ViewModel, including a page reached from another (`LibraryViewModel.detail(for:)` makes a
  `GameDetailViewModel`). A question about an element is a method (`cover(for:)`), about the whole
  a property (`isStreaming`).
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
never (`loading`) or fail (`failed`), via `PreviewReply`; the View's own `.task` does the rest
([swift-style.md](swift-style.md#preview-data)). The preview services are
`PreviewAccountService`, `PreviewConsoleService`, `PreviewCloudLibraryService`,
`PreviewStreamService` and `PreviewStreamConnection`. A stream preview never shows a first frame.

| Member | Gives |
|---|---|
| `appViewModel(signedIn:)`, `appViewModel(streamPhase:)` | An `AppViewModel` with one preview account or none, optionally already streaming |
| `signInViewModel(phase:)` | A `SignInViewModel` that reaches that phase |
| `homeViewModel(state:consoles:)`, `libraryViewModel(state:games:access:)` | Per-account ViewModels whose loads succeed, hang or fail |
| `gameDetailViewModel`, `settingsViewModel` | The first preview game's page; Settings on the previews' own `UserDefaults` suite |
| `streamViewModel(phase:dialogs:)`, `cloudStreamViewModel(phase:)` | A started `StreamViewModel` in that phase |
| Values (`consoles`, `cloudGames`, `systemDialogs`, …) and states (`queuedPhase`, `failedLoadState`, …) | Made-up values and states to pass in |
