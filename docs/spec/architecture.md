# Architecture

What every platform shares (accounts, library, stream, settings, palette) is written once in the
packages; what a person sees and touches is written per platform.

- macOS 26, visionOS 26, tvOS 26, and iOS 26 on iPhone and iPad, or later.
- Swift 6 language mode, Swift tools 6.2, Xcode 26. SwiftUI and Observation only. MVVM.
- No backend of our own, no analytics, no third-party SDK except WebRTC.

## Modules

![Modules: four platform apps over StarfoldShared, which uses XboxKit and StreamKit](images/modules.svg)

- `Starfold<Platform>/`: one app per platform (Mac, Vision, TV, iOS), with its views, navigation
  and system bridges; `StarfoldTopShelf/`: the Apple TV Top Shelf extension.
- `Preview Content/`: `PreviewObjectPool`, compiled into the apps as Development Assets.
- `Packages/StarfoldShared`: every feature's ViewModel and values, services, storage and shared
  interface pieces; TopShelfKit, the Top Shelf snapshot.
- `Packages/XboxKit`: sign-in, tokens, profile, consoles, cloud catalogue, session REST API.
- `Packages/StreamKit`: WebRTC, data channels, input, rendering, frame pacing, quality.

| Module | May import | Never imports |
|---|---|---|
| A platform app | StarfoldShared, XboxKit, StreamKit, its platform's frameworks | another platform's folder |
| StarfoldShared | XboxKit, StreamKit, SwiftUI, frameworks every platform has | AppKit, UIKit, RealityKit, an app |
| StreamKit | XboxKit, LiveKitWebRTC, AVFoundation, CoreAudio, CoreMedia, CoreVideo, Metal, MetalFX, CoreHaptics, GameController, UIKit outside macOS | SwiftUI |
| XboxKit | Foundation, Security, Synchronization, Compression, os | SwiftUI, WebRTC, StreamKit |
| TopShelfKit | Foundation | everything else |
| StarfoldTopShelf | TVServices, TopShelfKit | everything else |

A dependency not in this table is not allowed; adding one changes the table first.

- XboxKit and StreamKit know nothing about the apps: no strings, no assets, no `Preferences`;
  what they need arrives through an initializer.
- XboxKit owns HTTP and the shapes of Microsoft's responses; StreamKit owns everything after a
  session has an SDP answer ([streaming.md](streaming.md)).
- StarfoldShared's public surface is what the apps and `Preview Content/` use; everything else is
  internal. Its strings and resources are read with `bundle: .module`.
- Every package builds, tests and previews on its own, opened without the apps.
- The bundle identifier, App Group and Microsoft client ID come from
  `Configuration/Starfold.xcconfig`, the project's base configuration, and reach the code through
  Info.plist keys (`StarfoldAppGroup`, `StarfoldMicrosoftClientID`). The Keychain service and log
  subsystem derive from the bundle identifier. `AppDependencies` and `TopShelfStore` read those
  keys; XboxKit receives the client ID through `AccountStore`'s initializer.

## One target per platform

`StarfoldMac`, `StarfoldVision`, `StarfoldTV` and `StarfoldiOS` share the bundle identifier
`$(STARFOLD_BUNDLE_ID)`, product name `Starfold` and module name `Starfold`. A target compiles its
own folder and `Preview Content/`, and links the three packages (Apple TV also TopShelfKit).

- StarfoldShared never decides by platform: `#if os(…)` appears only where a system API is
  missing on a platform (`onHover` on tvOS, `controlActiveState` outside macOS,
  `StreamRuntime.setDirectStereo` on the Mac).
- Behaviour that differs is passed in by the platform app: an initializer argument, a closure, or
  a platform-owned value (`StreamPlatform`).
- A platform folder (`Starfold<Platform>/`) never contains `#if os(…)`.
- StreamKit renders with Metal on Mac, iPhone and iPad and with the system video layer on Vision
  Pro and Apple TV; its `#if os(…)` blocks sit in the rendering and input types that wrap those
  APIs.
- Touch controls use Apple's Touch Controller, which exists only on iOS: only
  `StarfoldiOS/Platform/Touch/` imports it. StreamKit treats the controller it creates like any
  other and learns which one it is from the product category `StreamPlatform` passes in.
- Info.plists and entitlements are in each target's `Configuration/`: `StarfoldMac.entitlements`
  (App Sandbox, network client and server, microphone, USB and Bluetooth controllers),
  `StarfoldVision.entitlements` (low-latency streaming), `StarfoldTV.entitlements` and
  `StarfoldTopShelf.entitlements` (App Group `$(STARFOLD_APP_GROUP)`). `StarfoldiOS` has no
  entitlements; its Info.plist names a launch screen and all four iPad orientations, without
  which an upload is rejected.
- The Mac target keeps `@executable_path/../Frameworks` in its runpath, or the installed app quits
  at launch (`LiveKitWebRTC.framework` is in `Contents/Frameworks`).

## Isolation

| Module | Default isolation |
|---|---|
| App targets | `MainActor` (`SWIFT_DEFAULT_ACTOR_ISOLATION`, `SWIFT_APPROACHABLE_CONCURRENCY`) |
| StarfoldShared, TopShelfKit | `MainActor` (`defaultIsolation` in `Package.swift`) |
| XboxKit, StreamKit | nonisolated; every public value is `Sendable` |

- Every module enables `MemberImportVisibility`.
- In the apps and StarfoldShared, write no isolation keyword; `nonisolated` goes only on the
  narrowest declaration used off the main actor (the Top Shelf extension and the TopShelfKit
  values it reads, `StreamConnection`, which the input queue calls). A type conforming to it
  inherits it.
- In XboxKit and StreamKit, `@MainActor` marks only what the interface calls synchronously
  (`ControllerHub`). Network work is `async` on actors (`StreamController`) or `Sendable` values;
  per-frame work runs on the renderer's queue.
- `@unchecked Sendable` and `nonisolated(unsafe)` appear only in StreamKit's thread-crossing types:
  the WebRTC, audio and Metal wrappers and the input types shared by the controller queue and the
  input thread. Each guards its mutable state with a lock.

## Folders

- A target's root holds its entry point and folders only (`StarfoldMacApp.swift`,
  `ContentProvider.swift`).
- An app's `Features/` has one folder per main page: `SignIn`, `Home`, `Library`, `Settings`,
  `Stream`. A page reached from a main page (game detail) sits inside its feature.
- A feature has the same name and path in each app (its Views) and in StarfoldShared (its
  ViewModel): `StarfoldMac/Features/Home/HomeView` shows `StarfoldShared/Features/Home/HomeViewModel`.
- Interface pieces every platform uses are in StarfoldShared's `UserInterface/`; pieces one
  platform uses are in that platform's `UserInterface/`, in the same layers (`Buttons/`,
  `Modifiers/`, `Components/`, `Dimensions/`); a view one feature uses is in its `Components/`.
- A folder exists once it has a file and is named for what it holds. No `Shared/`, `Helpers/`,
  `Utils/`, `Common/`, `Managers/`, `Debug/`.
- Tests mirror the source path ([testing.md](testing.md)).

## A platform app

- A feature folder holds that platform's main View(s) at the top, views only it uses in
  `Components/`, and `Model/` and `Presentation/` only for values and wording that platform alone
  uses (`HomeCardStatus`).
- Views have no platform prefix: `HomeView` is a different type in each app.
- Beside `Features/`: `Navigation/` (how pages are reached), `Platform/` (wrapped system APIs,
  grouped by the feature they serve) and `UserInterface/`.
- Every app has the same shape: the entry point, `Features/`, `Navigation/`, `Platform/`,
  `UserInterface/`, `Resources/` and `Configuration/`. On Vision Pro, Apple TV, iPhone and iPad,
  `Navigation/` holds `RootView` and a `…HostView` per tab.
- Logic a platform folder would otherwise hold goes to StarfoldShared when it can be tested on
  macOS (which touch controls a layout has and where they go is `TouchLayoutPlanner`).

## StarfoldShared

- A feature folder holds its ViewModel at the top, the values it shows (`Model/`) and their
  display text (`Presentation/`).
- A value lives in the top-level `Model/` when a service or storage signature needs it or several
  features share it; otherwise in its feature's `Model/`.
- Each app creates exactly one `AppViewModel`, through
  `AppDependencies(streamPlatform: StreamPlatform()).makeAppViewModel()`, and puts it in the
  environment.
- No singletons, `shared` instances or service locators.

## The packages

XboxKit and StreamKit are grouped in domain folders (`Auth/`, `Streaming/`, `Input/`,
`Rendering/`, …). A package's root holds only folders.

A type with more than one job is split by job, not by size: `StreamController` drives the
lifecycle, `HostChannels` decides the data-channel conversation as pure values the controller
performs.
