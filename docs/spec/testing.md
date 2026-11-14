# Testing and Previews

## Tests

- Swift Testing only (`@Test`, `#expect`, `#require`); no XCTest, no UI tests.
- Every test is a package test on macOS; `scripts/test.sh` runs them.
- One test file per source file with logic, at the mirrored path
  (`StarfoldSharedTests/Features/Library/LibraryViewModelTests.swift`), holding one
  `struct <Type>Tests`.
- Test behaviour that can go wrong silently: every intent and state change, every encoded field and
  message, every request and parse failure, persistence round trips, every branch that maps host
  output. Not views, simple getters or the frameworks.
- A ViewModel test uses stubs, its own `UserDefaults` suite and cache folder; never the Keychain or
  the network.
- A test that depends on the machine's hardware is skipped with `.enabled(if:)` and a reason.
- A bug's test is written first and seen failing.

## Test shape

```swift
@Test
func refreshConsolesThenListsThemByNameWithTheirState() async {
    // Given
    let (_, service, home) = makeHome()
    service.listed = .success([.dummyLivingRoom(powerState: .on), .dummyBedroom])

    // When
    await home.refreshConsoles()

    // Then
    #expect(home.consoles.map(\.name) == ["Bedroom", "Living room"])
}
```

- Name: `<method>When<condition>Then<result>`; drop `When…` when there is no condition.
- Sections: `// Given`, `// When`, `// Then`. Merge two when one line does both
  (`// When / Then`, `// Given / When`); none when the body is only the expectation. Never a
  `// When` or `// Then` without the sections before it.
- One behaviour per test; variations use `@Test(arguments:)`.
- The subject is built by a `make…` function with defaults, in a `private extension <Type>Tests` at
  the end.
- No sleeping on the clock: await the call, drive an injected clock, or use `Eventually`.

## Doubles and fixtures

No mocking frameworks; each test target has its own doubles.

- `Stubs/`: one stand-in per file, `<Role>Stub` (`AccountServiceStub`).
- `Dummies/`: fixtures as `static var dummy…` / `static func dummy…(…)` in an extension, one
  `<Type>Dummy.swift` per type. `dummy` for the only one, `dummy<Name>` for one of several
  (`Console.dummyLivingRoom`).
- `Support/`: other helpers, named for what they do (`Eventually`, `AppHarness`).
- Tests never use `PreviewObjectPool`. Names, gamertags and IDs are made up.

## Previews

- A View's `#Preview`s sit at the end of its file, in `#if DEBUG`.
- A screen previews each state the canvas can't produce (loading, empty, failure, content); a row
  or card stacks its variants; a style shows every case.
- Colour scheme, Dynamic Type and orientation are checked with canvas variants, not modifiers,
  except where the platform is always dark.
- Data comes only from `PreviewObjectPool` in `Preview Content/` (compiled into the apps as
  Development Assets): an `enum` of computed static members named after their value
  (`consoles`, `homeViewModel(consoles:)`), one file per area, building real ViewModels on
  `Preview…` services. StarfoldShared's own previews use design values only.
- Preview services answer at once (`loaded`), never (`loading`) or fail (`failed`), so the View's
  own `.task` drives the preview.
- Fake data is never a production default: no default argument or preset holds a sample account,
  game or console.
