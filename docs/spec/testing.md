# Testing and Previews

## Swift Testing

- Every test uses Swift Testing (`import Testing`, `@Test`, `#expect`, `#require`). No XCTest, no
  UI test target.
- One test file per source file with logic, mirroring its path:
  `StarfoldShared/Features/Library/LibraryViewModel.swift` →
  `StarfoldSharedTests/Features/Library/LibraryViewModelTests.swift`;
  `StarfoldShared/Services/Preferences.swift` →
  `StarfoldSharedTests/Services/PreferencesTests.swift`.
  Pure declarations (a protocol, an enum without members) have none.
- A test file holds one `struct <Type>Tests` and never covers two source files.

| Code | Tested in | Runs on |
|---|---|---|
| StarfoldShared: the ViewModels, their `Model/` and `Presentation/`, services, storage, colours, the String Catalogs | `Packages/StarfoldShared/Tests/StarfoldSharedTests`, no host app | macOS |
| TopShelfKit | `Packages/StarfoldShared/Tests/TopShelfKitTests`, no host app | macOS |
| XboxKit, StreamKit | `Packages/<Package>/Tests/<Package>Tests`, no host app | macOS |
| `StarfoldTV/` | `StarfoldTVTests`, hosted by the Apple TV app | tvOS Simulator |

- No test is hosted by the Mac or Vision Pro app. A ViewModel test builds its own ViewModels on
  stubs, with its own `UserDefaults` suite and cache folder, and never touches the Keychain or
  the network.
- Logic that can be tested on macOS lives where macOS tests reach it: input routing for Apple TV
  is in StreamKit, not in `StarfoldTV/`.

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
    #expect(home.consolesState == .loaded)
    #expect(home.consoles.map(\.name) == ["Bedroom", "Living room"])
    #expect(home.consoles.first?.hasWirelessWarning == true)
}
```

- Name: `<method>When<condition>Then<result>`; drop `When…` when there is no condition. No display
  name strings.
- Section comments are the only comments in tests, and each test uses one of these shapes:
  - `// Given`, `// When`, `// Then` (the sample above).
  - `// Given`, `// Then` when the arrangement is the call under test, or `// Given` and
    `// When / Then` when the call is the expectation itself.
  - `// Given / When`, `// Then` when the step that builds the subject is the step under test.
  - No comment at all when the body is only the expectation.

  A lone `// Then` is never written, and `// When` never appears without `// Given` before it.
- One behaviour per test; several `#expect`s may describe one outcome. Variations use
  `@Test(arguments:)`, not copied tests.
- The system under test is built by a `make…` function in a `private extension <Type>Tests` at
  the end of the file, with defaults for every collaborator.
- Tests never sleep on a wall clock: they await the method under test, drive time through an
  injected clock, or wait for a condition with `Eventually`.
- A test for a bug is written first and seen failing before the fix.

## What is tested

Only behaviour that can go wrong silently: protocol encoding and parsing, token and session
lifecycles, domain rules, state transitions, persistence, and missing translations. Views,
simple getters and the frameworks themselves are not unit-tested.

| Type | Tests |
|---|---|
| A model | Every intent, every state transition, cancellation |
| Protocol encoding | Every field's bytes, every message shape, both directions |
| Request types and parsing | Path, method, headers, body; every field and every failure |
| Persistence | Round trip, the stored keys and formats |
| Presentation extensions | Every `switch` branch that maps host output to advice |
| String Catalogs | Every catalog in the repository: every key semantic, commented, in English and Chinese, none stale; every language shipped |

## Test doubles

Every test target keeps what its tests stand on in three folders. No mocking frameworks. There
is no shared test library: a double or fixture two test targets need exists in each
(`XboxServerStub` in `StarfoldSharedTests` and `XboxKitTests`).

| Folder | Holds | Named |
|---|---|---|
| `Stubs/` | Test doubles: whatever stands in for a collaborator, one per file | `<Role>Stub` (`AccountServiceStub`, `XboxServerStub`, `ClockStub`, `CallCountStub`) |
| `Dummies/` | Fixtures: [dummy extensions](swift-style.md#preview-data), one file per extended type | `<Type>Dummy.swift` (`ConsoleDummy.swift`) |
| `Support/` | Other helpers | After what they do (`AppHarness`, `Eventually`, `LocalizationCatalog`, `XboxEndpoint`) |

- `Stub` is the only suffix of a test double, whether it returns canned values, records the calls
  it receives or is a working lightweight implementation.
- A dummy extension is `nonisolated` when used in `@Test(arguments:)`.
- Tests never use `PreviewObjectPool`: it is preview data, not a fixture.

## Running

`scripts/test.sh` runs every package's tests on macOS with no app host. `StarfoldTVTests` run
when `TV_DESTINATION` names a tvOS simulator.

## Previews

One `#Preview` at the end of each View file, inside `#if DEBUG` (an archive leaves out
`Preview Content/`, which the previews use). Never a separate preview file.

| View | How its states are shown |
|---|---|
| Screen | One `#Preview` per platform-relevant state the canvas cannot produce (loading, empty, failure, content), or one `#Preview(_:arguments:)` over them |
| Row, card, section | One `#Preview` stacking every data variant |
| Style or palette | Every case side by side |
| Small view with nothing to vary | One plain `#Preview`, or none if it only makes sense in its parent |

- Data and ViewModels come from [`PreviewObjectPool`](swift-style.md#preview-data)
  (`PreviewObjectPool.homeViewModel()`, `PreviewObjectPool.appViewModel(signedIn: true)`), built on preview
  services ([view-models.md](view-models.md#previews)).
- Colour scheme, Dynamic Type and orientation are checked with the canvas Variants; previews never
  set `.preferredColorScheme` or `.dynamicTypeSize`, except where the platform is always dark
  (Apple TV, the stream window).
