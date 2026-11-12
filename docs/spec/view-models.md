# ViewModels

Starfold is MVVM. A screen's View lays out values and forwards what the person does; its
ViewModel holds the state and every decision about it. The ViewModels are shared by all three
platforms and live in StarfoldShared, one per feature, in `StarfoldShared/Features/<Feature>/`:
the same path under which each app keeps that feature's Views.

## The ViewModels

| ViewModel | Lives | Owns |
|---|---|---|
| `AppViewModel` | The app's lifetime; one per app, in the environment | Whether someone is signed in, the accounts, the profile, the signed-in account's `HomeViewModel` and `LibraryViewModel`, the current `StreamViewModel` and each request to show it |
| `SignInViewModel` | One sign-in screen | The device code and its renewal, retrying, the step the sign-in panel shows, when the sheet closes, the welcome page's features |
| `HomeViewModel` | One signed-in account | Consoles and which of the row's contents applies (`consolesContent`), each console's status, cover and power control, playing a console, the power problem and its alert |
| `LibraryViewModel` | One signed-in account | Cloud games, recently played, curated rows, favourites, the search text and its results, sort, each shelf's games, which placeholder applies |
| `GameDetailViewModel` | One game's page | The game, its artwork, inputs and facts as values ready to show, whether it is a favourite, playing it |
| `SettingsViewModel` | The app's lifetime | The settings a person changes, the choices each offers and their names, the connected controllers, the accounts to switch between, signing out, restarting a stream for new settings |
| `StreamViewModel` | One stream | Phase, statistics, host dialogs, the renderer, input wiring |

`AppViewModel` creates the per-account and per-stream ViewModels, and each sign-in screen's
`SignInViewModel` through `makeSignInViewModel()`. A feature's View never creates a ViewModel:
`Navigation/` hands it one. The welcome page and the Add Account sheet get theirs from
`SignInHostView`, which asks `AppViewModel` for a new one when the screen appears and keeps it
while the screen is shown.

## Services

A ViewModel talks to the outside world only through the services it is given. A service is a
protocol in `StarfoldShared/Services/`, with its live implementation beside it:

| Service | Does | Live implementation |
|---|---|---|
| `AccountService` | Restores signed-in accounts, runs the device-code sign-in, signs out | Xbox sign-in through XboxKit's `AccountStore` |
| `ConsoleService` | Lists one account's consoles, what they play, sends power commands | XboxKit's console and Xbox Live clients |
| `CloudLibraryService` | Loads one account's cloud titles, catalogue details, curated lists | XboxKit's GSSV and catalogue clients |
| `StreamService` | Starts a stream to a console or cloud title and reports its updates | StreamKit's `StreamController` |

### Signatures

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

- **The account handle.** `AccountService` answers with `SignedInAccount`: the account's
  `AccountSummary` (xuid and gamertag) and that account's `ConsoleService`,
  `CloudLibraryService` and `StreamService`. Nothing in it holds a token, so a preview or a test
  builds one from made-up values and its own services. `AppViewModel` keeps the handles by xuid
  and builds each account's `HomeViewModel` and `LibraryViewModel` on its services. The live
  services wrap that account's XboxKit `XboxAccount`; `LiveAccountService` keeps the
  `XboxAccount`s it handed out to read the profile.
- **Errors.** Services throw XboxKit's errors; a ViewModel turns
  `XboxAccountError.signInRequired` into `onSignInRequired`, which `AppViewModel` sets to raise
  `isSignInExpired`.
- **A stream.** `StreamService.connect(to:options:)` signs in to the right GSSV service and answers
  with a `StreamConnection` (`updates`, `start(sink:)`, `stop(reason:)`, `setGamepad`,
  `pressGuide()`, `requestKeyframe()`, `answerDialog`, `answerKeyboard`), which the live service
  backs with StreamKit's `StreamController`. `StreamViewModel.start()` connects in a `Task` it
  owns and reads the connection's updates until the stream ends.
- **What a stream shows.** `StreamViewModel` answers every question its three screens ask:
  `status` (a `StreamStatus`: connecting, queued with a formatted wait, ended with the reason and
  its `StreamFailureAdvice`), `isWaitingForPicture`, `isShowingControls` (revealed by
  `revealControls()`, hidden again after the platform's `controlsHideDelay`),
  `isShowingStatistics` and `statisticsReadout` (a `StatisticsReadout`: the latency with its
  `LatencyLevel`, and one formatted `StatisticsRow` for each `StatisticsRowKind` the platform
  lists in `StreamOverlays`), `presentedDialog`, `buttons(of:)`, `textFieldTitle(of:)` and the
  bindable `dialogText` (drafted from the host's default, cut to its limit), `canOpenMenu`,
  `isPlayable`, `needsController`, `sharpeningLevel` and `statisticsReport(device:)`. It applies
  the picture, buffer and sound settings itself, when it is created and whenever `Preferences`
  changes, so no screen forwards a setting. `tryAgain()` asks `AppViewModel` for a new stream
  through `onRestart`; closing a stream stays with `Navigation/`, which owns the window or cover.
- **What lives where.** The live services hold the protocol's quirks (the console list falling
  back to SmartGlass, cloud access derived from the playable titles, catalogue joins); the
  ViewModels hold state, order (consoles and games by name) and the saved snapshots: each
  per-account ViewModel restores and saves its own part through `LibraryCache`
  (`HomeSnapshot`: consoles and the last game seen on each; `LibrarySnapshot`: games, recent,
  curated rows, access).
- **Settings.** `SettingsViewModel` exposes every setting as a bindable property backed by
  `Preferences`, the choices each picker offers (`qualityChoices`, `bitrateChoices`,
  `gameLanguages`, `pictureFits`, `pacingModes`, `soundStages`) and the names a choice has no
  presentation for (`title(ofBitrate:)`, `name(ofGameLanguage:)`), what the platform allows
  (`canEnhancePicture`, `canChoosePictureFit`, `canToneMapHDR`), effective values
  (`effectiveGameLanguage`), the connected controllers (`isControllerMissing`,
  `playerNumber(of:)`, `batteryLevel(of:)`) and key bindings. What needs the app is an intent or
  a query too: `accountChoices` and `switchAccount(to:)`, `signOutSubject` and `signOut()`,
  `needsStreamRestart` and `restartStream()`.
- **Narrow dependencies.** A ViewModel that needs the app sees only the part it uses, as a
  protocol `AppViewModel` conforms to: `SigningIn` (begin and complete a device-code sign-in) for
  `SignInViewModel`, `SessionControlling` (the accounts, switching, signing out, restarting the
  stream) for `SettingsViewModel`. Tests give them a stub.
- **Sections.** Which sections a platform's Settings has is that platform's `SettingsView`: its
  `body` lists them. A row that depends on the device or the session asks the ViewModel
  (`canToneMapHDR`, from the `PictureCapabilities` the platform passed in; `needsStreamRestart`).

Storage is plain types the services and ViewModels are given: `Preferences` (settings in
`UserDefaults`), `FavoritesStore`, `LibraryCache`. Services, storage and the values in their
signatures (`SignedInAccount`, `CloudLibrary`) are `public` where an app or a preview builds or
reads them.

`AppDependencies`, in `StarfoldShared/App/`, is the composition root: it builds the live services
once and hands them to `AppViewModel`. Previews get the same ViewModels from `PreviewObjectPool`,
built on preview services; tests build them on stubs. No ViewModel has a preview-only or
debug-only entry point.

## Shape

- `@Observable public final class <Feature>ViewModel`, in `StarfoldShared/Features/<Feature>/`
  with the values it shows (`Model/`) and their presentation (`Presentation/`); each platform's
  views of the feature are in `Starfold<Platform>/Features/<Feature>/`.
- `public` on the class and on what the apps and `Preview Content/` use: its initializer, the
  state and queries a View reads, the intents a View calls. Stored state a View reads is
  `public private(set) var`.
- Imports Foundation, Observation, XboxKit and StreamKit as needed; never SwiftUI, AppKit, UIKit
  or RealityKit; never reads the environment.
- Its strings, and those of its `Model/` and `Presentation/`, are in StarfoldShared's catalog
  (`String(localized: "stream.failure.signInExpired", bundle: .module)`,
  [localization.md](localization.md)).
- Every dependency is an `init` parameter, stored as `private let`. No default arguments that hold
  services or data.
- Behaviour that differs by platform arrives as a value (`StreamPlatform`,
  `PictureCapabilities`), never as `#if os(…)` inside a ViewModel.
- What the Views use is `public`, what only the package and its tests use is `internal`,
  everything else is `private`.

## State

- Stored state is `private(set) var` (`public private(set) var` when a View reads it). The only
  writable `var`s are values a View binds to
  (`isSignInExpired`, `powerProblem`, a setting).
- What something is doing is one enum (`SessionState`: `restoring`, `signedOut`, `signedIn`;
  `LoadState`: `idle`, `loading`, `loaded`, `failed`), never a set of booleans and optionals.
- Lists a View renders are derived (`shelves`, `visibleGames`, `coverArtwork(limit:)`),
  never a second stored copy.
- `@ObservationIgnored` is not written by default: a `private var` no View can reach (a task, a
  timer, a counter) has no observers, so tracking it changes nothing, and a `private var` behind
  a property a View reads must stay tracked. It appears only where the compiler requires it (a
  property wrapper, a `lazy var`) or where a value is deliberately kept from refreshing Views,
  with the reason in [decisions.md](decisions.md).

## Intents and queries

Every user action is one method named after what the person does (`play(_:)`, `signOut()`,
`switchAccount(to:)`, `togglePower(of:)`, `openGuide()`). An intent guards its precondition, changes
state, then starts work.

The View asks; it never computes ([views.md](views.md#what-a-view-may-decide)). Every page has a
ViewModel, including a page reached from another (`GameDetailViewModel`, made by
`LibraryViewModel.detail(for:)`), so a page's decisions are written once for all three platforms
and tested. A question about an element is a method (`cover(for:)`,
`activity(for:)`), a question about the whole a property (`isStreaming`,
`needsRestartForSettings`).

An action that needs the app is still an intent of the page's ViewModel, which holds a closure
`AppViewModel` sets when it creates the ViewModel: `HomeViewModel.play(_:)` and
`LibraryViewModel.play(_:)` call `onPlay` with the `StreamTarget`,
`HomeViewModel.refreshAccount()` calls `onRefreshAccount`, and `GameDetailViewModel.play()` goes
through the library that made it. `AppViewModel` starts the stream itself, unless the platform
set `onPlayRequest` to take the request first (Apple TV's `StreamPresenter`, which asks for a
controller).

## Async work

- Work a screen starts and owns runs from the View's `.task` / `.task(id:)` and is `async` on the
  ViewModel (`refresh()`, `SignInViewModel.run()`), so SwiftUI cancels it with the screen.
- Work that must outlive any one View is a `Task` the ViewModel owns and cancels: the account's
  initial load, the console refresh while the app is active, a stream's update loop.
- Loads that run together are combined with `async let` in the ViewModel, never in a View.
- Cancellation is checked right after each `await`; a cancelled load changes nothing.
- Old content stays visible during a refresh; the saved snapshot shows until the first refresh
  replaces it.

## Previews

A preview shows a real ViewModel in a real state: `PreviewObjectPool` builds it on a preview
service that answers at once (`loaded`), never answers (`loading`) or fails (`failed`), and the
View's own `.task` does the rest. All of it lives in the single top-level `Preview Content/`
([swift-style.md](swift-style.md#preview-data)).

| Member | Gives |
|---|---|
| `appViewModel(signedIn:)` | An `AppViewModel` that restores one preview account (or none) at once |
| `appViewModel(streamPhase:)` | The same, already playing the first console in that phase |
| `signInViewModel(phase:)` | A `SignInViewModel` whose account service leads to that phase once its screen runs it |
| `homeViewModel(state:consoles:)` | A `HomeViewModel` whose consoles load, never load or fail |
| `libraryViewModel(state:games:access:)` | A `LibraryViewModel` whose library loads, never loads or fails |
| `gameDetailViewModel` | The `GameDetailViewModel` of the first preview game |
| `streamViewModel(phase:dialogs:)`, `cloudStreamViewModel(phase:)` | A started `StreamViewModel` whose connection reports that phase, statistics and dialogs |
| `statisticsReadout`, `messageDialogButtons` | What a statistics panel and a game dialog are given |
| `settingsViewModel`, `favorites` | Settings and favourites on the previews' own `UserDefaults` suite |
| `signInCode`, `signInSteps`, `accountChoices` | What a sign-in panel and an account list are given |
| `profile`, `deviceCodePrompt`, `consoles`, `cloudGames`, `streamStatistics`, `systemDialogs`, `messageDialog`, `keyboardDialog`, `messageDialogTitle`, `messageDialogText`, `textPromptTitle`, `textPromptDescription`, `textPromptText` | Made-up values |
| `signInPhases`, `failedSignInPhase`, `failedLoadState`, `queuedPhase`, `hostNotRegisteredPhase`, `signInExpiredPhase` | States to pass in |

The preview services are `PreviewAccountService`, `PreviewConsoleService`,
`PreviewCloudLibraryService`, `PreviewStreamService` and `PreviewStreamConnection`; a
`PreviewReply` turns a `LoadState` into answering, never answering or failing. A stream preview
never shows a first frame: no decoded picture reaches the renderer, so `hasFirstFrame` stays
false.

## Review checklist

- [ ] Named `…ViewModel`, at the top of its feature folder in StarfoldShared, `public` only on
  what the apps use, no SwiftUI import, no `#if os(…)`, no `#if DEBUG`.
- [ ] Every dependency injected; the outside world reached only through a service.
- [ ] Every stored state property is `private(set)` or deliberately writable.
- [ ] One enum per independent activity.
- [ ] Every user action is a named intent; every question the View asks is a named query.
- [ ] Every `Task` the ViewModel creates is stored and cancelled; cancellation checked after each
  `await`.
