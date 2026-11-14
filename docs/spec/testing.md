# Testing and Previews

## Swift Testing

- Swift Testing only (`@Test`, `#expect`, `#require`). No XCTest, no UI test target.
- One test file per source file with logic, mirroring its path:
  `StarfoldShared/Features/Library/LibraryViewModel.swift` →
  `StarfoldSharedTests/Features/Library/LibraryViewModelTests.swift`. Pure declarations have none.
- A test file holds one `struct <Type>Tests` and covers one source file.

| Code | Tested in | Runs on |
|---|---|---|
| StarfoldShared: ViewModels, `Model/`, `Presentation/`, services, storage, colours, String Catalogs | `Packages/StarfoldShared/Tests/StarfoldSharedTests` | macOS |
| TopShelfKit | `Packages/StarfoldShared/Tests/TopShelfKitTests` | macOS |
| XboxKit, StreamKit | `Packages/<Package>/Tests/<Package>Tests` | macOS |

- Every test is a package test on macOS; no test target is hosted by an app.
- A ViewModel test builds its ViewModels on stubs, with its own `UserDefaults` suite and cache
  folder, and never touches the Keychain or the network.
- Logic testable on macOS lives where macOS tests reach it (Apple TV input routing is in
  StreamKit).
- `scripts/test.sh` runs them ([workflow.md](workflow.md#commands)).

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

- Name: `<method>When<condition>Then<result>`; drop `When…` without a condition. No display names.
- Section comments, one of these shapes:
  - `// Given`, `// When`, `// Then`;
  - `// Given`, `// Then` when the arrangement is the call under test, or `// Given`,
    `// When / Then` when the call is the expectation;
  - `// Given / When`, `// Then` when building the subject is the step under test;
  - none when the body is only the expectation.

  Never a lone `// Then`, never `// When` without `// Given` before it.
- One behaviour per test; several `#expect`s may describe one outcome. Variations use
  `@Test(arguments:)`.
- The system under test is built by a `make…` function, with defaults for every collaborator, in a
  `private extension <Type>Tests` at the end of the file.
- No wall-clock sleeps: await the method, drive an injected clock, or wait with `Eventually`.
- A test for a bug is written first and seen failing.

## What is tested

Behaviour that can go wrong silently. Views, simple getters and the frameworks are not
unit-tested.

| Type | Tests |
|---|---|
| A model | Every intent, every state transition, cancellation |
| Protocol encoding | Every field's bytes, every message shape, both directions |
| Request types and parsing | Path, method, headers, body; every field and every failure |
| Persistence | Round trip, the stored keys and formats |
| Presentation extensions | Every `switch` branch that maps host output to advice |
| String Catalogs | [localization.md](localization.md#testing) |

A test whose result depends on the machine's hardware (an audio output, a paired controller) is
gated with `.enabled(if:)` or `.disabled(if:)`, a reason, and a check in `Support/`
(`AudioOutputAvailability`, `ControllerAvailability`), so it is skipped rather than failing on that
machine.

## Test doubles

No mocking frameworks and no shared test library: a double two test targets need exists in each.

| Folder | Holds | Named |
|---|---|---|
| `Stubs/` | Anything standing in for a collaborator (canned, recording or lightweight working), one per file | `<Role>Stub` (`AccountServiceStub`, `ClockStub`) |
| `Dummies/` | Fixtures: [dummy extensions](swift-style.md#preview-data), one file per extended type | `<Type>Dummy.swift` (`ConsoleDummy.swift`) |
| `Support/` | Other helpers | After what they do (`Eventually`, `AppHarness`) |

Tests never use `PreviewObjectPool`.

## Previews

A View file's `#Preview`s sit at its end, inside `#if DEBUG`; never a separate preview file.

| View | How its states are shown |
|---|---|
| Screen | One `#Preview` per state the canvas cannot produce (loading, empty, failure, content), or one `#Preview(_:arguments:)` over them |
| Row, card, section | One `#Preview` stacking every data variant |
| Style or palette | Every case side by side |
| Small view with nothing to vary | One plain `#Preview`, or none if it only makes sense in its parent |

- Data and ViewModels come from [`PreviewObjectPool`](swift-style.md#preview-data), built on
  preview services ([view-models.md](view-models.md#previews)).
- Colour scheme, Dynamic Type and orientation are checked with canvas Variants; previews never set
  `.preferredColorScheme` or `.dynamicTypeSize`, except where the platform is always dark (Apple
  TV, the stream window).
