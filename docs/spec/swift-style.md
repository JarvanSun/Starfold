# Swift Style

## Formatting

`.swift-format` fixes layout; `scripts/format.sh` applies it and `scripts/format.sh --lint` must
succeed.

- 4-space indentation, 100 columns. A declaration or call that fits on one line is written on one
  line. A protocol requirement that runs a little past 100 columns stays on one line like its
  siblings, marked `// swift-format-ignore` (`AccountService.completeSignIn`).
- A comma-separated list fits on one line, or every element (the first included) goes on its own
  line. Never mix.
- One blank line between declaration groups, between sibling views ([views.md](views.md#siblings))
  and after a `guard`. Never two blank lines in a row.
- In a function each step is a paragraph separated by one blank line. A `let` stays with the
  statement right after it that uses it; consecutive assignments of one value's fields stay
  together. Every block (`if`, `switch`, `for`, `while`, `do`) has a blank line before and after,
  unless it opens or closes its scope.

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

- `#if` blocks are not indented.

## Files

- Every Swift file starts with the Xcode header: file name, module name, `Created by <author> on
  <yyyy/MM/dd>.`; the date never changes. In `Package.swift` it follows `// swift-tools-version:`.
- One top-level type per file, named after it; a `private` helper type used only by it may stay.
- An extension of another module's type goes in `<Type>Extensions.swift` (`URLExtensions.swift`),
  never `URL+Upgrade.swift`. Any other extension of our own type in its own file is named after
  what it adds (`CatalogProductParsing.swift`).
- A model's presentation (titles, symbols, colours, accessibility text) goes in
  `<Type>Presentation.swift`. What every platform shows is presented once in StarfoldShared (the
  feature's `Presentation/`, or `UserInterface/`); only wording one platform alone uses is in that
  app. A presentation returns `LocalizedStringResource`, never a resolved `String`, and only picks
  words, symbols and colours.
- Nothing lives at file level except types and their extensions (the `Package.swift` manifest
  excepted). A helper goes below the member it serves ([Declaration order](#declaration-order)),
  in an extension of the value type it works on, or in a small `private` helper type.

## Naming

| Kind | Rule | Good | Bad |
|---|---|---|---|
| Type | Noun phrase for what it is | `ControllerHub` | `ControllerManager` |
| Capability protocol | `-ing` | `SecretStoring` | `SecretStoreProtocol` |
| Boolean | `is` / `has` / `can` / `should` | `isStreaming` | `streaming` |
| Intent method | Verb phrase the user would say | `play(_:)` | `handleTap()` |
| Query method | Noun phrase or `is…(_:)` | `cover(for:)` | `getCover(_:)` |
| Closure property | What happens | `onRetry` | `callback` |
| Test double | `Stub` suffix | `XboxServerStub` | `MockStuff` |
| ViewModel property | The type's name | `homeViewModel: HomeViewModel` | `home: HomeViewModel` |
| Dependency property | The type's name; for a capability protocol, its role without `-ing` | `consoleService: ConsoleService`, `networkPath: NetworkPathReading` | `service`, `network` |

- No abbreviations except `ID`, `URL`, `API`, `JSON`, `HTTP`, `HDR`, `SDR` and the protocol's terms
  (`xuid`, `GSSV`, `SDP`, `ICE`).
- Never `data`, `info`, `item`, `object`, `value`, `manager`, `helper`, `handle` or `util` as a
  whole name; as a suffix only in a domain phrase (`DeviceInfoHeader`).
- Do not prefix a member with its owner's name just to say whose it is (`console.name`, not
  `console.consoleName`). A word the owner also uses is fine when the member is named after its own
  type or contents (`controllerHub.connectedControllers`, `streamViewModel.streamService`), or when
  it turns a broad word into a specific one (`KeychainStore.keychainService`; `service` alone says
  nothing).
- A ViewModel property keeps the type's name, and a value it holds is named for what it is
  (`consoleCover`, not `cover`).
- Name a value after what it means at that point (`restored`, then `preferred`).
- A stored property says what it is and what it is for, read without its type:
  - one holding a dependency (a service, store, cache, client, hub, runtime or platform) takes its
    type's name (`controllerHub: ControllerHub`, `libraryCache: LibraryCache`); one typed by a
    capability protocol takes the role without `-ing` (`secretStore: SecretStoring`). Initializer
    labels match the property;
  - a collection or a piece of state names what it holds (`connectedControllers`, not
    `connected`; `inputState`, not `state`);
  - a word that could mean two things in the module gets its qualifier (`keyboardGamepad`, not
    `keyboard`; `backgroundTask`, not `task`; `audioEngine`, not `engine`);
  - it keeps the word of its type that says what kind of thing it is (`homePath`, not `path`;
    `xboxButtonSettings`, not `xboxButton`; `orientationLock`, not `orientation`;
    `selectedTab`, not `selection`), unless it is that value itself (`palette: PaletteID`,
    `pacing: PacingMode`).
- Methods that do different jobs do not share one generic verb as overloads: `receive(_ update:)`,
  `move(to phase:)`, `record(_ statistics:)`, not four `apply(_:)`.
- Short names stay where one meaning is certain: `log` (the type's one `Logger`), `lock`, `body`,
  `id`, `defaults` (`UserDefaults`), and a property already named after its type (`renderer:
  StreamRenderer`, `preferences: Preferences`).

## Declaration order

Inside a type, one blank line between groups:

1. Nested types (small `private` ones only).
2. `@Environment`, `@State`, `@Binding` properties (views).
3. Stored properties, grouped by identical access, widest first: `public` (`let`, then `var`),
   `public private(set)`, `internal`, `private let`, `private var`. One blank line between groups,
   none inside a group. Callback closure properties (`on…`) form one group of their own whatever
   their access, right after the `public` stored properties (`public` callbacks first, then
   `internal`).
4. Computed properties, in the same access order.
5. Initializers.
6. `body` (views).
7. Intents, in the order the user meets them.
8. Queries.

A private helper sits right below the member it serves, in call order: a step one method uses
follows that method, a part of `body` follows `body`. A helper several members share follows the
first of them and stays there when a later member calls it too; a private computed property several
members share joins the computed properties.

```swift
func connect() {
    prepare()
    open()
}

private func prepare() { … }

private func open() { … }

func reconnect() {
    close()
    open()
}

private func close() { … }
```
Extensions group protocol conformances, members of a type declared in another file, and private
decoding types, never members by access level.

```swift
@Observable
public final class LibraryViewModel {
    public let favorites: FavoritesStore

    public var onSignInRequired: () -> Void = {}
    var onPlay: (StreamTarget) -> Void = { _ in }

    public private(set) var games: [CloudGame] = []
    public private(set) var cloudState: LoadState = .idle

    private let service: CloudLibraryService
    private let preferences: Preferences

    private var refreshTask: Task<Void, Never>?
}
```

In an `@Observable` type, `@ObservationIgnored` properties, when there are any, form the last stored
group. A `let` is never marked `@ObservationIgnored`.

### Section marks

A file under 150 lines has no `// MARK:`. A longer file puts one `// MARK: - <Name>` directly
above each top-level extension, followed by one blank line:

| Extension | Name |
|---|---|
| The `private extension` holding a file's private nested types | `Private` |
| A conformance | The protocol: `Equatable` |
| Another extension of the file's type | What it groups: `Sections` |
| An extension of another type | That type: `URL` |
| The `#Preview`s at the end of the file | `Previews` |

Marks never appear on the type's own declaration, inside a type or function, or in a test file.

## Access control

- Default is `internal`, written without a modifier.
- `public` only in the packages, and only on what an app target uses.
- Members used only in the file are `private`; `fileprivate` only when a second type in the file
  needs the member.
- Classes are `final`.
- A `public` type writes out a `public` initializer.
- Tests use `@testable import`; never widen access for a test.

## Functions

- One responsibility: if describing a function needs "and", split it.
- A file reads top-down: main type, its intents and queries in the order a person meets them,
  then the private steps in call order. The top function reads like a table of contents.
- A function with several jobs is split into private methods, or into a type when one job has
  state or rules worth testing alone (`HostChannels`). No type for a job a private method does.
- Split a function that does not fit on one screen or nests more than two levels.
- At most four parameters; more means a value type is missing (`StreamDependencies`).
- A protocol type is written bare (`secretStore: SecretStoring`); `ExistentialAny` is off, so `any`
  and `some` appear only where the compiler needs them (`clock: some Clock<Duration>`, stored as
  `any Clock<Duration>`; `some View`).
- No boolean parameters that change behaviour (`load(force: true)`): two intents or an enum.

### `.init` from context

Write `.init(…)` where the surrounding declaration states the type: the single-expression body or
`return` of a function or computed property of that type (and each `switch` value of such a
body), a property, parameter default or `let` with an explicit type, an argument whose parameter
type is stated, an enum payload, an element of a typed collection literal.

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

Keep the type name where nothing nearby states it (`let home = HomeViewModel(…)`), for a SwiftUI
view built in a `body` or `@ViewBuilder`, and where `.init` is ambiguous (`String(localized:)`).

## Control flow

- `guard` for preconditions. Consecutive entry `guard`s and their `defer` form one block; `defer`
  sits after the entry `guard`s and the declarations its cleanup needs.
- A `switch` case whose body is a single value goes on its label's line (`case nil: sessionState
  = .signedOut`), unless it does not fit in 100 columns.
- `switch` over an enum, an optional with more than one outcome, or a tuple of deciding values.
  `if / else` for a choice between two outcomes of one condition, and `if / else if` for a
  fallback chain tried in order. Never a series of early `return`s standing in for either.
- A `switch` that produces a value is an expression; a single-expression property or function
  omits `return`.
- Unwrap with the shorthand: `guard let self`, `if let stream`.
- Mutually exclusive states are an `enum`, never a set of optionals and booleans.
- Name compound conditions before using them (`let isHostingTests = …`).
- A ternary picks between two values on one condition, above all a `Bool`
  (`isSelected ? .primary : .secondary`), in code and in a view's `body`; never nested, never for
  side effects.
- No force unwraps or `try!` outside tests and previews, except a `URL` from a string literal.

## Errors

- Typed throws for APIs that throw one error enum; prefer them for new ones.
- What the host says when a stream fails becomes `StreamFailureAdvice` through an exhaustive
  `switch`; its presentation is the text the person reads ([streaming.md](streaming.md#errors)).
- `try?` only when the caller does not care why something failed; otherwise `do / catch`.

## No magic values

A literal that carries meaning gets a name, as close to its use as it can be. Never a `Constants`
type.

- Used in one function: a local `let` there (`let staggerInterval = 0.08`).
- Shared by several members of a type: a `private let` on the type.
- Differs per platform or caller: an initializer argument (`StreamPlatform`).
- A computed property only for a value derived from state.

| Literal | Lives in |
|---|---|
| User-facing text | String Catalog, written where used ([localization.md](localization.md)) |
| Colours | `Palette`, or semantic `Color` extensions (`.online`) |
| Lengths | `Dimensions` ([user-interface.md](user-interface.md#spacing-and-sizes)) |
| Button looks | `PrimaryButtonStyle`, `CircleIconButtonStyle` |
| Endpoints, headers, JSON keys | The XboxKit client that sends them, `CodingKeys` |
| Protocol bytes and message names | StreamKit enums (`GamepadButton`, `InputReportType`) |
| `UserDefaults` keys | `Preferences`' private key enum |
| A closed set of names | An `enum` with raw values |

`0`, `1`, `""` and `[]` as neutral starting values are not magic; dummy data may be literal.

## No `static`

No `static` (or `class`) member, except:

1. a member a protocol requires (`==`, `<`);
2. an extension giving a protocol-typed SwiftUI or Foundation parameter its leading dot
   (`extension ButtonStyle where Self == PrimaryButtonStyle { static var primary }`,
   `LocalizedStringResource.BundleDescription.module`);
3. an `@Entry` in `EnvironmentValues` or `FocusedValues`;
4. a member of [`PreviewObjectPool`](#preview-data);
5. a `static var dummy…` / `static func dummy…(…)` in a test target's dummy extension;
6. a `private static let` holding one immutable value that every instance shares and that is
   costly to build (a `DateFormatter`, a `Regex`, a lookup table).

Nothing else is `static`: no `static var`, `static func` or non-`private` static outside the list,
and a new kind of exception is added to this list first.

A preset is an enum case (`PrimaryButtonSize.compact`) or an initializer with real values; a
helper is an instance member or initializer (`XboxDateParser().date(from:)`); something shared for
the app's life is owned by an instance the composition root creates (`StreamRuntime`).

## Preview data

- `PreviewObjectPool` in the top-level `Preview Content/` is the only preview data. The apps
  compile it as Development Assets (`DEVELOPMENT_ASSET_PATHS`). Every file in `Preview Content/`
  and every `#Preview` is wrapped in `#if DEBUG`; there are no other debug-only branches, loaders,
  launch arguments or screens. When one seems unavoidable, ask the owner before writing it.
- `PreviewObjectPool` is an `enum` of computed static members, so each access returns a fresh value
  or ViewModel. It supplies data only; each `#Preview` stays at the end of its View's file.
- An area of the pool is its own file, `PreviewObjectPool<Responsibility>.swift`; the preview
  services it builds ViewModels on are `Preview<Service>` types beside it.
- A member is named after its value without a `dummy` prefix (`consoles`,
  `homeViewModel(consoles:)`) and used as `PreviewObjectPool.x`. What only the pool needs is
  `private`, or `internal` when another pool file builds on it.
- The pool builds ViewModels with their public initializers on preview services. StarfoldShared's
  own `#Preview`s (in `UserInterface/`) use no pool and no sample models, only design values.

```swift
extension PreviewObjectPool {
    static var profile: XboxProfile {
        .init(xuid: "2535000000000000", gamertag: "NovaPilot", gamerscore: 12480, pictureURL: nil)
    }
}
```

- Fake data is never a production default: no default argument, stored default or preset holds a
  sample account, game or console.
- Test fixtures never use the pool: a `static var dummy…` (or `static func dummy…(…)` with
  parameters) in an extension of its type, one `<Type>Dummy.swift` per type in the test target's
  `Dummies/` ([testing.md](testing.md#test-doubles)). `dummy` for a type's only value,
  `dummy<Name>` for one of several, `dummy<Role>` for a list (`Console.dummyLivingRoom`); used as
  `Type.dummyX`, or `.dummyX` where the context type is exactly that type; `nonisolated` when used
  off the main actor.
- Names, gamertags and IDs in preview data and fixtures are made up.

## Comments

- No explanatory comments: no `//` notes, no `///`, no trailing comments. A reason no name can
  carry goes in [decisions.md](decisions.md).
- The only comments are `// swift-tools-version`, [section marks](#section-marks), and `// Given`
  / `// When` / `// Then` in tests. No commented-out code, `TODO`s or banners.

## Extensions and collections

- Extend a standard type only to name an intention used in more than one place
  (`Logger(category:)`).
- Never extend a concrete collection (`extension [CloudGame]`); a collection with rules is a domain
  type. Rules about one element belong to the element (`Console.isReachable`).

## Concurrency

- Swift 6 strict concurrency; isolation follows [architecture.md](architecture.md#isolation),
  async work and cancellation [view-models.md](view-models.md#async-work).
- Shared mutable state off the main actor is guarded by an `actor`, `Synchronization.Mutex`, or,
  in the StreamKit types allowed `@unchecked Sendable`, an `NSLock` or `NSCondition`.
