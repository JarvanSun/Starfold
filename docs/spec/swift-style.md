# Swift Style

## Layout

`scripts/format.sh` formats; `scripts/format.sh --lint` must pass. Beyond what it fixes:

- What fits on one line is one line; a list is all on one line or one element per line.
- One blank line between declaration groups, sibling views and after a `guard`.
- A function is paragraphs: one blank line between steps, and around every `if`, `switch`, `for`,
  `while`, `do` unless it opens or closes the scope. A `let` stays with the line that uses it.

## Files

- Starts with the Xcode header (file, module, `Created by … on yyyy/MM/dd.`); the date never
  changes.
- One top-level type per file, named after it. A small `private` helper type may stay with it.
- An extension of another module's type: `<Type>Extensions.swift`. Another extension of our own
  type: named for what it adds (`CatalogProductParsing.swift`). Never `URL+Upgrade.swift`.
- Titles, symbols, colours and accessibility text for a type: `<Type>Presentation.swift`. It only
  picks words, symbols and colours, returns `LocalizedStringResource`, and lives in StarfoldShared
  unless only one platform shows it.
- Nothing at file level but types and extensions.

## Naming

| Kind | Rule | Good | Bad |
|---|---|---|---|
| Type | What it is | `ControllerHub` | `ControllerManager` |
| Capability protocol | `-ing` | `SecretStoring` | `SecretStoreProtocol` |
| Boolean | `is` / `has` / `can` / `should` | `isStreaming` | `streaming` |
| Intent | What the person does | `play(_:)` | `handleTap()` |
| Query | Noun or `is…(_:)` | `cover(for:)` | `getCover(_:)` |
| Factory | `make…` when it only creates a new object | `makeGameDetailViewModel(for:)` | `detail(for:)` |
| Closure property | What happened | `onRetry` | `callback` |
| Test double | `…Stub` | `XboxServerStub` | `MockServer` |
| ViewModel or dependency property | Its type's name | `homeViewModel`, `consoleService` | `home`, `service` |
| Capability-protocol property | Its role | `secretStore: SecretStoring` | `secrets` |

A property, read alone, says what it is:

- It keeps the word that says what kind of thing it is: `homePath`, `xboxButtonSettings`,
  `orientationLock`, `selectedTab`, not `path`, `xboxButton`, `orientation`, `selection`. Not
  when it is the value itself: `palette: PaletteID`.
- A collection or state says what it holds: `connectedControllers`, `inputState`.
- A word with two meanings gets a qualifier: `keyboardGamepad`, `backgroundTask`, `audioEngine`.
- Initializer labels match the properties they set.

Also:

- Don't prefix a member with its owner's name just to say whose it is (`console.name`, not
  `console.consoleName`). Overlap is fine when the member is named for its own type or contents
  (`controllerHub.connectedControllers`) or a broad word needs it (`keychainService`).
- Different jobs never share one verb as overloads: `receive(_:)`, `move(to:)`, `record(_:)`, not
  four `apply(_:)`.
- A method returning a cached instance it creates the first time is not a factory
  (`connectedController()`).
- A new object that needs only its own data comes from its initializer (`ZipEntry.Method(code:)`);
  one that needs the creator's dependencies comes from the creator's `make…`
  (`AccountStore.makeXboxAccount(from:)`). No `static` factories.
- No abbreviations but `ID`, `URL`, `API`, `JSON`, `HTTP`, `HDR`, `SDR` and protocol terms (`xuid`,
  `GSSV`, `SDP`, `ICE`). Never `data`, `info`, `item`, `object`, `value`, `manager`, `helper`,
  `handle`, `util` as a whole name.
- Short names are fine where only one meaning is possible: `log`, `lock`, `body`, `id`,
  `defaults`, `renderer: StreamRenderer`.

## Declaration order

1. Nested types (small, `private`).
2. `@Environment`, `@State`, `@Binding`.
3. Stored properties by access, widest first; `on…` closures as their own group after the `public`
   ones; `@ObservationIgnored` last (never on a `let`).
4. Computed properties.
5. Initializers.
6. `body`.
7. Intents, in the order the person meets them.
8. Queries.

A private helper goes right below the first member that calls it, in call order, and stays there
when later members call it too:

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

A file over 150 lines marks each top-level extension with `// MARK: - <Name>`: `Private` for
private nested types, the protocol for a conformance, the type for another type's extension,
`Previews` for previews. No other marks.

## Access

- `internal` by default, unwritten. `public` only in packages, only for what an app uses, with a
  `public` initializer.
- `private` for what one file uses; `fileprivate` only when a second type in the file needs it.
- Classes are `final`. Tests use `@testable import`; never widen access for a test.

## Functions

- One job each; split when describing it needs "and", when it doesn't fit a screen, or nests more
  than two levels. A job with its own state or rules becomes a type (`HostChannels`).
- At most four parameters; more means a value type is missing.
- No Boolean parameter that changes behaviour (`load(force:)`): two methods or an enum.
- `any` / `some` only where the compiler needs them.
- Write `.init(…)` where the type is stated right there (return type, typed property or argument,
  enum payload); keep the type name elsewhere and for views in a `body`.

## Control flow

- `guard` for preconditions.
- `switch` for an enum, an optional with several outcomes or a tuple of conditions. A one-value
  case stays on its label's line.
- `if / else` for two outcomes of one condition; `if / else if` for a fallback chain.
- A ternary picks one of two values (`isSelected ? .primary : .secondary`), also in a `body`;
  never nested, never for side effects.
- Mutually exclusive states are one `enum`, not several Booleans and optionals.
- Name a compound condition before using it (`let isHostingTests = …`).
- Unwrap with the shorthand (`if let stream`).
- No `!` or `try!` outside tests and previews, except `URL(string:)` of a literal.

## Errors

- Typed throws for APIs with one error enum.
- `try?` only when the reason doesn't matter; otherwise `do / catch`.

## Values with meaning

A literal that means something gets a name next to where it is used: a local `let`, a
`private let` when several members share it, an initializer argument when it differs by platform.
Never a `Constants` type. `0`, `1`, `""`, `[]` as starting values are fine.

| Literal | Home |
|---|---|
| Text people read | String Catalog ([localization.md](localization.md)) |
| Colours, lengths | `Palette` and `Color` extensions; `Dimensions` |
| Endpoints, headers, JSON keys | The XboxKit client, `CodingKeys` |
| Protocol bytes and names | StreamKit enums |
| `UserDefaults` keys | `Preferences` |
| A closed set of names | An `enum` with raw values |

## `static`

Only for:

1. what a protocol requires (`==`);
2. leading-dot styles (`static var primary` on `ButtonStyle`), `BundleDescription.module`;
3. `@Entry` in `EnvironmentValues` / `FocusedValues`;
4. `PreviewObjectPool` and test `dummy…` members;
5. a `private static let` for one costly shared value (a formatter, a `Regex`).

Nothing else, and a new kind of exception is added to this list first. A preset is an enum case;
something shared for the app's life is owned by an instance the composition root creates.

## No debug code

Only `#Preview`s and `Preview Content/` are debug-only (`#if DEBUG`). No other debug branches,
launch arguments or screens; if one seems necessary, ask the owner first. Previews and their data:
[testing.md](testing.md#previews).

## Comments

No comments except `// swift-tools-version`, section marks and `// Given` / `// When` / `// Then`.
A reason no name can carry goes in [decisions.md](decisions.md).

## Extensions

- Extend a standard type only for an intention used in several places (`Logger(category:)`).
- A question about one value belongs on that value (`control.isShown`, not `isShown(control)`).
- Never extend a concrete collection; a collection with rules is its own type.
- An extension groups a conformance, members of a type declared elsewhere, or private decoding
  types, never members by access level.

## Concurrency

Swift 6 strict concurrency; isolation in [architecture.md](architecture.md#isolation), async work
in [view-models.md](view-models.md#async-work). Shared state off the main actor is guarded by an
`actor` or `Mutex` (an `NSLock` only in StreamKit's `@unchecked Sendable` types).
