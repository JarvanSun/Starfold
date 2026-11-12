# Swift Style

Code reads top to bottom like prose: every name says what a thing is, every function does one
thing, and nothing needs a comment.

## Formatting

Layout a tool can decide is fixed in `.swift-format` and applied by `scripts/format.sh`;
`scripts/format.sh --lint` must succeed.

- 4-space indentation, 100 columns.
- A comma-separated list (arguments, parameters, array literals, generic requirements) fits on one
  line, or every element goes on its own line, the first one included. Never mix.
- One blank line between declaration groups, between sibling views
  ([views.md](views.md#siblings)), and after a `guard`. Never two blank lines in a row.
- In a function, each step is its own paragraph: statements that do different things are
  separated by one blank line. A `let` stays with the statement right after it that uses it, and
  consecutive assignments of one value's fields stay together.
- A `guard` stands alone with one blank line after it. Every block (`if`, `switch`, `for`,
  `while`, `do`) is its own paragraph, with a blank line before and after it unless it opens or
  closes its scope.

  ```swift
  func restart() async {
      guard !isEnding, let target else { return }

      restartRequest += 1
      let request = restartRequest

      await finish()

      let isStillRequested = !Task.isCancelled && request == restartRequest
      if isStillRequested { start(target) }
  }
  ```
- A declaration or call that fits in 100 columns is written on one line; it wraps only when it
  doesn't.
- `#if` blocks are not indented.
- When the type is known from context, write `.init(...)` instead of repeating the type name
  ([details](#init-from-context)).

## Files

- Every Swift file starts with the Xcode header: file name, module name, `Created by <author> on
  <yyyy/MM/dd>.`; the date never changes. In `Package.swift` the header follows
  `// swift-tools-version:`.
- One top-level type per file, named after the type. A `private` helper type used only by the
  file's main type may stay in that file.
- An extension of a type from another module goes in `<Type>Extensions.swift`
  (`URLExtensions.swift`), never `URL+Upgrade.swift`.
- Presentation of a model (titles, symbols, colors, accessibility text) goes in
  `<Type>Presentation.swift` (`PictureFitPresentation.swift`). What every platform shows is
  presented once, in the feature's `Presentation/` in StarfoldShared (or in its `UserInterface/`
  for its own interface pieces); only wording one platform alone uses is in that app's folder of
  the feature. A presentation returns `LocalizedStringResource`, never a
  resolved `String`, and decides nothing beyond picking words, symbols and colours for a value.
- Any other extension of our own type in its own file is named after what it adds
  (`CatalogProductParsing.swift`).
- Preview data goes in `PreviewObjectPool` under the top-level `Preview Content/`
  (`PreviewObjectPool.swift`, `PreviewObjectPoolStreams.swift`); a test fixture for a type goes in
  the test target's `Dummies/<Type>Dummy.swift` (`ConsoleDummy.swift`), whichever module the type
  comes from ([Dummy data](#preview-data)).
- Nothing lives at file level except types and their extensions: every `func`, `let` and `var`
  belongs to a type. A helper goes in the file's trailing `private extension <Type>`, in an
  extension of the value type it works on (`private extension AppDependencies { var
  savedLibrariesDirectory: URL }`), or in a small `private` helper type. The only exception
  is a `Package.swift` manifest.

## Naming

| Kind | Rule | Good | Bad |
|---|---|---|---|
| Type | Noun phrase for what it is | `ControllerHub`, `LibrarySnapshot` | `LibraryData`, `ControllerManager` |
| Capability protocol | `-ing` | `SecretStoring`, `VideoFrameReceiving` | `SecretStoreProtocol` |
| Boolean | `is` / `has` / `can` / `should` | `isStreaming`, `hasFirstFrame` | `streaming`, `firstFrameFlag` |
| Intent method | Verb phrase the user would say | `play(_:)`, `openGuide()` | `handleTap()`, `didPress()` |
| Query method | Noun phrase or `is…(_:)` | `cover(for:)`, `needsNewStream(for:)` | `getCover(_:)` |
| Closure property | What happens | `onRetry`, `onSelect` | `callback`, `handler` |
| Test double | `Stub` suffix | `XboxServerStub`, `CallCountStub` | `MockStuff`, `TestHelper` |

- No abbreviations except `ID`, `URL`, `API`, `JSON`, `HTTP`, `HDR`, `SDR` and the protocol's own
  terms (`xuid`, `GSSV`, `SDP`, `ICE`): `controller`, not `ctrl`; `microsoftAccountToken`, not
  `msa`.
- Never `data`, `info`, `item`, `object`, `value`, `manager`, `helper`, `handle` or `util` as a
  whole name; as a suffix only in a domain phrase (`DeviceInfoHeader`).
- Do not repeat the type in member names: `console.name`, not `console.consoleName`.
- Name a value after what it means: `restored` while it is what the Keychain returned,
  `preferred` once chosen.

## Declaration order

Inside a type, one blank line between groups; inside a group, the order in which the screen or
caller uses them.

1. Nested types (small `private` ones only; anything bigger gets its own file).
2. `@Environment`, `@State`, `@Binding` properties (views).
3. What the initializer is given: the `let`s (and a view's `@Bindable var`) set from its
   parameters, in parameter order, `private` ones included.
4. Stored state, by access, widest first: `public`, then `internal`, then `private(set)`, then
   `private`.
5. Computed properties, in the same access order.
6. Initializers.
7. `body` (views).
8. Intents, in the order the user meets them.
9. Queries.
10. A trailing `private extension <Type>` with private computed properties and steps, in call
    order.

```swift
@Observable
final class LibraryViewModel {
    let favorites: FavoritesStore
    private let accountID: String
    private let service: CloudLibraryService
    private let preferences: Preferences
    private let cache: LibraryCache

    var onSignInRequired: () -> Void = {}
    private(set) var games: [CloudGame] = []
    private(set) var recentGames: [CloudGame] = []
    private(set) var cloudState: LoadState = .idle
    private let log = Logger(category: .library)

    var sort: GameSort {
        get { preferences.librarySort }
        set { preferences.librarySort = newValue }
    }

    var favoriteGames: [CloudGame] {
        games.filter { favorites.contains($0.id) }
    }

    init(accountID: String, service: CloudLibraryService, preferences: Preferences, cache: LibraryCache) {
        …
    }
}
```

A `let` is never marked `@ObservationIgnored`: Observation tracks only `var`s.

### Section marks

A file under 150 lines has no `// MARK:`. A longer file puts one `// MARK: - <Name>` directly
above each top-level extension, followed by one blank line:

| Extension | Name |
|---|---|
| The trailing `private extension` of the file's type | `Private` |
| A conformance (`extension X: Equatable`) | The protocol: `Equatable` |
| Another extension of the file's type | What it groups: `Sections`, `Streaming` |
| An extension of another type | That type: `URL`, `JSONDecoder` |
| The `#Preview`s at the end of the file | `Previews` |

The type's own declaration has no mark; marks never appear inside a type, a function or a test
file.

## Access control

- Default is `internal`, written without a modifier.
- `public` only in the packages, and only on what an app target uses. Everything an app target
  declares is `internal`.
- Members used only in the file are `private`; `fileprivate` only when a second type in the file
  needs the member.
- Classes are `final`.
- A `public` type writes out a `public` initializer; the memberwise one is never relied on across
  modules.
- Tests use `@testable import`. Never widen access for a test.

## Functions

- One responsibility: if describing a function needs "and", split it.
- A file reads top-down: its main type first, then its intents and queries in the order a
  person meets them, then the private steps they call, in call order.
- The top function reads like a table of contents of well-named private steps.
- A function that grows several jobs is split: into private methods when the jobs are small, into
  a type of its own when one job has state or rules worth testing alone (`HostChannels`,
  `StatisticsCollector`). A type is not created for a job a private method does.
- A function that does not fit on one screen, or nests more than two levels, is split.
- At most four parameters; more means a value type is missing (`StreamDependencies`,
  `PictureCapabilities`).
- A protocol type is written bare, as a parameter and as a stored property:
  `secrets: SecretStoring`, `private let secrets: SecretStoring`. The project does not enable
  `ExistentialAny`, so `any` and `some` appear only where the compiler needs them: a protocol with
  an associated or primary associated type (`clock: some Clock<Duration>`, stored as
  `any Clock<Duration>`), an opaque result (`some View`), or a generic use that needs it.
- No boolean parameters that change behaviour (`load(force: true)`): two intents or an enum
  (`TokenFreshness.refreshRequired`).

### `.init` from context

Write `.init(…)` when the surrounding declaration already states the type:

- the single-expression body of a function or computed property, or a `return`, of that type;
- each value of a `switch` that is such a body;
- a property, a parameter default or a `let` with an explicit type annotation;
- an argument whose parameter type is stated, an enum payload, and an element of a collection
  literal whose element type is stated.

```swift
func signedInToken(_ accessToken: String, from reply: TokenResponse) -> MicrosoftAccountToken {
    .init(
        accessToken: accessToken,
        refreshToken: reply.refreshToken,
        expiresAt: expiry(of: reply),
        userID: reply.userID
    )
}
```

Keep the type name where nothing nearby states it (`let home = HomeViewModel(…)`), for a
SwiftUI view built inside a `body` or `@ViewBuilder`, and where `.init` would be ambiguous
(`String(localized:)`).

## Control flow

- `guard` for preconditions, followed by one blank line. Consecutive entry `guard`s and their
  `defer` form one block.
- `defer` sits after the entry `guard`s and the declarations its cleanup needs, never in the middle
  of the main logic.
- A `switch` case whose body is a single value goes on the same line as its label. A case that
  does not fit in 100 columns stays wrapped as the formatter leaves it; a case with several
  statements, or a value spanning several lines, stays as it is.

  ```swift
  func activateOrShowWelcome(_ account: SignedInAccount?) {
      switch account {
      case let account?: activate(account)
      case nil: sessionState = .signedOut
      }
  }
  ```

- **Branch with `switch`**: over an enum, a tuple of the deciding values, an optional or a `Bool`.
  `if` only for one condition without `else`. Never `if / else`, an `else if` chain or a series of
  early `return`s.
- A `switch` that produces a value is an expression (`let backdrop = switch target { … }`); a
  single-expression property or function omits `return`.
- Unwrap with the shorthand: `guard let self`, `if let stream`.
- Mutually exclusive states are an `enum`, never a set of optionals and booleans.
- Name compound conditions before using them (`let isHostingTests = …`).
- Ternaries only to pick between two simple values (`isOn ? .high : .standard`); never nested,
  never for side effects.
- No force unwraps or `try!` outside tests and previews, except a `URL` from a string literal.

## Errors

- Throwing APIs that already throw one error enum use typed throws; prefer typed throws for new
  ones.
- What the host says when a stream fails becomes `StreamFailureAdvice` with an exhaustive
  `switch`; the text the person reads is its presentation ([streaming.md](streaming.md)).
- `try?` only when the caller does not care why something failed; otherwise `do / catch`.

## No magic values

A literal that carries meaning gets a name, once, in the place that owns it.

| Literal | Lives in |
|---|---|
| User-facing text | String Catalog, written where it is used ([localization.md](localization.md)) |
| Colours | `Palette`, or the semantic `Color` extensions (`.online`, `.cardFill`) |
| Button looks | `PrimaryButtonStyle`, `CircleIconButtonStyle` |
| Endpoints, headers, JSON keys | The XboxKit client that sends them, `CodingKeys` |
| Protocol bytes and message names | StreamKit enums (`GamepadButton`, `InputReportType`, `MessageTarget`) |
| `UserDefaults` keys | `Preferences`' private key enum |
| Durations, limits, retry counts | A property of the type that uses them, or an initializer argument |

`0`, `1`, `""` and `[]` as neutral starting values are not magic. Dummy data may be literal
([Dummy data](#preview-data)).

A constant belongs to the type that uses it: a closed set of names is an `enum` with raw values; a
value one type uses is a computed property in its `private extension`
(`var fallbackConsoleType: String { "XboxSeriesX" }`); a value that differs per platform arrives
through an initializer (`StreamPlatform`). Never a `Constants` type.

## No `static`

Write no `static` (or `class`) member, except:

1. a member a protocol requires (`==`, `<`);
2. an extension that gives a protocol-typed SwiftUI or Foundation parameter its leading dot:
   `extension ButtonStyle where Self == PrimaryButtonStyle { static var primary }`,
   `extension ShapeStyle where Self == Color { static var online }`, and
   `LocalizedStringResource.BundleDescription.module`, which gives a package's strings the same
   `bundle: .module` that `Text` takes;
3. an `@Entry` in `EnvironmentValues` or `FocusedValues`;
4. a member of [`PreviewObjectPool`](#preview-data) (`PreviewObjectPool.consoles`,
   `PreviewObjectPool.homeViewModel(consoles:)`);
5. a `static var dummy…` or `static func dummy…(…)` in a test target's
   [dummy extension](#preview-data) (`Console.dummyLivingRoom`, `UserDefaults.dummyEmpty`).

Everything else has a non-static home:

- A preset is an enum case (`ControllerRouting.television`, `PrimaryButtonSize.compact`) or an
  initializer with real values (`StreamPlatform()` per platform).
- A helper is an instance member or an initializer (`XboxDateParser().date(from:)`,
  `HostICECandidate(_:).expanded`), never a file-scope function.
- Something shared for the life of the app (the WebRTC factory) is owned by an instance the
  composition root creates (`StreamRuntime`, created by `AppDependencies` and handed to every
  `LiveStreamService` through `LiveAccountService`).

## Preview data

Previews take their data and dependencies from `PreviewObjectPool`, the only preview data in the
project, in the top-level `Preview Content/` folder. The three app targets compile it as
Development Assets (`DEVELOPMENT_ASSET_PATHS`), so an archive leaves it out; that is why each
`#Preview` sits inside `#if DEBUG`, the only place the code uses it. There are no debug-only
branches, loaders, launch arguments or screens.

- `PreviewObjectPool` is an `enum` whose static members are computed, so every access returns a
  fresh value or ViewModel. It supplies data only; each `#Preview` stays at the end of its View's
  file.
- An area of the pool is its own file, `PreviewObjectPool<Responsibility>.swift`
  (`PreviewObjectPoolCloudGames.swift`, `PreviewObjectPoolStreams.swift`); the preview services the
  pool builds ViewModels on are `Preview<Service>` types beside it (`PreviewConsoleService`).
- A member is named after its value, without a `dummy` prefix: `profile`, `consoles`,
  `homeViewModel(consoles:)`, `streamViewModel(phase:)`. A use writes `PreviewObjectPool.x`.
- What the pool needs only to build its members is `private`, or `internal` when another pool
  file builds on it (`libraryCache`, `streamDependencies`, `consoleService(state:consoles:)`).
- The pool is compiled in the app module: it builds the ViewModels with their own public
  initializers, on preview services that implement StarfoldShared's service protocols.
  StarfoldShared's own `#Preview`s (in `UserInterface/`) use no pool and no sample models, only
  design values such as the palette cases.

```swift
import XboxKit

extension PreviewObjectPool {
    static var profile: XboxProfile {
        .init(xuid: "2535000000000000", gamertag: "NovaPilot", gamerscore: 12480, pictureURL: nil)
    }
}
```

Fake data is never a default value in production code: no default argument, stored property
default or preset holds a sample account, game or console.

Test fixtures are separate and never use the pool: a `static var dummy…`, or `static func dummy…(…)`
when it needs parameters, in an extension of the type it belongs to, one file per extended type
named `<Type>Dummy.swift` in the test target's `Dummies/`
([testing.md](testing.md#test-doubles)).

- `dummy` for the only value of a type, `dummy<Name>` for one of several, `dummy<Role>` for a list
  (`Console.dummyLivingRoom`, `CloudGame.dummyRecentGames(count:)`).
- A use writes `Type.dummyX`, or `.dummyX` where the context type is exactly that type.
- A dummy is `nonisolated` when it is used off the main actor (`@Test(arguments:)`).

Names, gamertags and IDs in preview data and fixtures are made up; never a real person's.

## Comments

- No explanatory comments: no `//` notes, no `///` documentation, no trailing comments. Rename or
  extract until the code explains itself. A reason that no name can carry (an OS bug, a measured
  timing, a protocol quirk) goes in [decisions.md](decisions.md), under the type it explains.
- The only comments are `// swift-tools-version`, the [section marks](#section-marks), and
  `// Given` / `// When` / `// Then` in tests.
- No commented-out code, `TODO`s or banners.

## Extensions and collections

- Extend a standard type only to name an intention used in more than one place
  (`URL(upgradingXboxImageToHTTPS:)`, `Logger(category:)`).
- Never extend a concrete collection (`extension [CloudGame]`). A collection with rules of its
  own is a domain type.
- Rules about one element belong to the element (`Console.isReachable`, `CloudTitle.isPlayable`).

## Concurrency

- Swift 6 strict concurrency. No `@unchecked Sendable` and no `nonisolated(unsafe)` outside the
  StreamKit types named in [architecture.md](architecture.md#isolation).
- Shared mutable state off the main actor is guarded by an `actor`, by `Synchronization.Mutex`, or,
  in those StreamKit types, by an `NSLock` or `NSCondition`.
- Async work and cancellation follow [view-models.md](view-models.md#async-work); isolation follows
  [architecture.md](architecture.md#isolation).
- Everything that exists only for previews is in the top-level `Preview Content/`.
