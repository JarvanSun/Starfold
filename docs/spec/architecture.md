# Architecture

Starfold is one product on three platforms. Everything a platform shares (accounts, the library,
the stream, settings, the palette) is written once; everything a person sees and touches is
written per platform, in that platform's own idiom.

- macOS 26, visionOS 26 and tvOS 26 or later. No iOS build.
- Swift 6 language mode, Swift tools 6.2, Xcode 26. SwiftUI and Observation only.
- MVVM: observable models own state and decisions, views lay them out.
- No backend of our own, no analytics, no third-party SDK except WebRTC.

## Modules

```text
Starfold.xcodeproj
├── StarfoldMac/            the Mac app: entry point, its views of every feature, navigation,
│                           AppKit bridges, Mac-only pieces
├── StarfoldVision/         the Vision Pro app, same shape
├── StarfoldTV/             the Apple TV app, same shape
├── StarfoldTopShelf/       the Apple TV Top Shelf extension
├── StarfoldTVTests/        tests of the Apple TV app's own code, hosted by the Apple TV app
├── Preview Content/        PreviewObjectPool and its preview services: the only preview data,
│                           compiled into the three apps as Development Assets
└── Packages/
    ├── StarfoldShared      what the three apps share: every feature's ViewModel and values,
    │                       services, storage, the shared interface pieces; and TopShelfKit,
    │                       the Top Shelf snapshot
    ├── XboxKit             Microsoft and Xbox Live: sign-in, tokens, profile, consoles,
    │                       cloud catalogue, the streaming session REST API
    └── StreamKit           the stream itself: WebRTC, data channels, input, rendering,
                            frame pacing, adaptive quality
```

| Module | May import | Never imports |
|---|---|---|
| A platform app | StarfoldShared, XboxKit, StreamKit, its platform's frameworks | another platform's folder |
| StarfoldShared | XboxKit, StreamKit, SwiftUI, frameworks every platform has | AppKit, UIKit, RealityKit, an app |
| StreamKit | XboxKit, LiveKitWebRTC, Apple's media, graphics and input frameworks (AVFoundation, CoreAudio, CoreMedia, CoreVideo, Metal, MetalFX, CoreHaptics, GameController), UIKit outside macOS | SwiftUI |
| XboxKit | Foundation, Security, Synchronization, os | SwiftUI, WebRTC, StreamKit |
| TopShelfKit | Foundation | everything else |
| StarfoldTopShelf | TVServices, TopShelfKit | everything else |

A dependency not in this table is not allowed; adding one changes the table first.

- XboxKit and StreamKit know nothing about the apps: no strings, no assets, no `Preferences`.
  What they need arrives through an initializer.
- StarfoldShared's public surface is what the apps and `Preview Content/` use and nothing more;
  everything else stays internal. Its strings and resources are read with `bundle: .module`.
- Every package builds, tests and previews on its own, opened without the apps.
- Identifiers live in the `com.jarvansun.sunbox` namespace: bundle identifiers, the App Group, Keychain
  services, log subsystems and queue labels.
- XboxKit owns HTTP and the shapes of Microsoft's responses; StreamKit owns everything after a
  session has an SDP answer. The protocol both implement is described in
  [streaming.md](streaming.md).

## One target per platform

Each platform is its own app target, `StarfoldMac`, `StarfoldVision` and `StarfoldTV`, with the
same bundle identifier (`com.jarvansun.sunbox`), product name (`Starfold`) and module name (`Starfold`). A
target compiles its own folder and `Preview Content/`, and links the three packages (Apple TV
also TopShelfKit), nothing else.

- StarfoldShared holds what behaves the same everywhere. It never decides by platform:
  `#if os(…)` appears in it only where a system API does not exist on one platform (`onHover` on
  tvOS, `controlActiveState` outside macOS; StreamKit's `StreamRuntime.setDirectStereo`, which
  wraps a spatial-audio API the Mac does not have), never to choose different behaviour.
- Behaviour that differs is passed in by the platform app: an initializer argument, a closure, or
  a value the platform owns (`StreamViewModel` receives the render settings its platform supports).
- A platform's folder (`Starfold<Platform>/`) never contains `#if os(…)`.
- StreamKit renders with Metal on Mac and through the system video layer on Vision Pro and Apple
  TV. Its `#if os(…)` blocks sit in the rendering and input types that wrap those APIs.
- Folders, Info.plists and entitlements are per target, in its `Configuration/` folder:
  `StarfoldMac.entitlements` (App Sandbox, network client and server, microphone, USB and
  Bluetooth controllers), `StarfoldVision.entitlements` (low-latency streaming),
  `StarfoldTV.entitlements` and `StarfoldTopShelf.entitlements` (the App Group
  `group.com.jarvansun.sunbox` the Top Shelf snapshot is shared through).
- The Mac target keeps `@executable_path/../Frameworks` in its runpath: a Mac app keeps
  `LiveKitWebRTC.framework` in `Contents/Frameworks`, and without it the installed app quits at
  launch.

## Isolation

| Module | Default isolation |
|---|---|
| App targets | `MainActor` (`SWIFT_DEFAULT_ACTOR_ISOLATION`, `SWIFT_APPROACHABLE_CONCURRENCY`) |
| StarfoldShared, TopShelfKit | `MainActor` (`defaultIsolation` in `Package.swift`) |
| XboxKit, StreamKit | nonisolated; every public value is `Sendable` |

- Every module enables `MemberImportVisibility`, so each file imports what it uses.
- In the apps and StarfoldShared, write no isolation keyword. `nonisolated` goes only on the
  narrowest declaration used off the main actor (a value built on the render queue, a `Shape`).
- In XboxKit and StreamKit, `@MainActor` marks only what the interface calls synchronously
  (`ControllerHub`). Network work is `async` on actors (`StreamController`) or `Sendable`
  values; per-frame work runs on the renderer's own queue.
- No `@unchecked Sendable` and no `nonisolated(unsafe)` outside StreamKit's types that cross
  threads: the WebRTC, audio and Metal wrappers that hold thread-safe Objective-C objects, and the
  input types shared by the controller queue and the input thread. Each guards its mutable state
  with a lock.

## Folders

The tree answers three questions before any file is opened: where the app starts, what it can do,
and where a reusable piece lives.

- **Where it starts.** A target's root holds its entry point and folders, nothing else:
  `StarfoldMacApp.swift` in `StarfoldMac/`, `ContentProvider.swift` in `StarfoldTopShelf/`.
- **What it can do.** An app's `Features/` has one folder per main page: `SignIn`, `Home`,
  `Library`, `Settings`, `Stream`. A page reached from a main page (a game's detail page) sits
  inside its feature, not beside it.
- **Views in the app, ViewModel in the package.** A feature has the same name and path in each
  app and in StarfoldShared: `StarfoldMac/Features/Home/`, `StarfoldVision/Features/Home/` and
  `StarfoldTV/Features/Home/` hold each platform's `HomeView`, and
  `StarfoldShared/Features/Home/` holds the `HomeViewModel` all three show.
- **Where a reusable piece lives.** Interface pieces every platform uses are in StarfoldShared's
  `UserInterface/`; pieces only one platform uses are in that platform's own `UserInterface/`,
  in the same layers (`Buttons/`, `Modifiers/`, `Components/`, `Dimensions/`); a view only one
  feature uses is in that feature's `Components/`.
- A folder exists once it has a file and is named for what it holds. No `Shared/`, `Helpers/`,
  `Utils/`, `Common/`, `Managers/`, `Debug/`.
- Tests mirror the source path: `StarfoldShared/Features/Home/HomeViewModel.swift` is tested in
  `StarfoldSharedTests/Features/Home/HomeViewModelTests.swift`.

## A platform app

```text
StarfoldMac/
├── StarfoldMacApp.swift  the entry point: its scenes
├── Features/
│   ├── SignIn/           SignInView, WelcomeView, Components/, Presentation/
│   ├── Home/             HomeView, Components/, Model/
│   ├── Library/          LibraryView, GameDetailView, Components/
│   ├── Settings/         SettingsView and its tabs (StreamingSettings, PictureSettings,
│   │                     ControlsSettings), Components/, Presentation/
│   └── Stream/           StreamView, Components/
├── Navigation/           MainWindowView, HomeRoute, MainToolbar, AccountMenu, ProfileBadge,
│                         StreamCommands, FocusedValuesExtensions, MenuBarMenu,
│                         StreamWindowView, StreamWindowOpener, SignInHostView
├── Platform/             AppKit bridges (Video/, Keyboard/, PictureInPicture/, FullScreen/),
│                         AppDelegate, StreamPlatformOnMac
├── UserInterface/        what only the Mac uses, in StarfoldShared's layers: Buttons/,
│                         Modifiers/, Components/, Dimensions/ (DimensionsOnMac)
├── Resources/            Assets.xcassets, AppIcon.icon, Localizable.xcstrings, PrivacyInfo
└── Configuration/        Info.plist, StarfoldMac.entitlements
```

- A feature's folder holds that platform's views of it: its main View (or Views) at the top, the
  views only it uses in `Components/`, and `Model/` and `Presentation/` only for values and
  wording that platform alone uses (`HomeCardHeading`, `HomeCardStatus`).
- Views are named after what they show, with no platform prefix: each target compiles one
  platform's folder, so `HomeView` is a different type in each app.
- What belongs to no single feature sits beside `Features/`: how the pages are reached
  (`Navigation/`), the system APIs the platform wraps (`Platform/`) and the pieces several of
  its features reuse (`UserInterface/`).
- `StarfoldVision/` has the same shape; its `Navigation/` holds `RootView`, `SignedInTabView` and
  `SignedInTab`, a `…HostView` per tab, `SignInHostView`, `AccountMenu` and `StreamWindowView`.
- `StarfoldTV/` has the same shape; its `Navigation/` holds `RootView`, `RootTab` and a
  `…HostView` per tab (Search included, whose results view lives in `Features/Library/`) and
  `SignInHostView`, and
  its `Platform/` also holds `Controller/`, `TopShelf/` and `Background/`.
- Platform code that wraps a system API is in `Platform/`, grouped by the feature it serves
  (`Platform/Video/`, `Platform/Keyboard/`, `Platform/PictureInPicture/`).

## StarfoldShared

```text
StarfoldShared/Sources/StarfoldShared/
├── App/                AppViewModel, AppDependencies (the composition root), AppInfo, SceneID;
│                       Model/ (SessionState)
├── Features/
│   ├── SignIn/         SignInViewModel, SigningIn, Model/ (SignInPhase, SignInStep,
│   │                   SignInCode, QRCode, WelcomeFeature), Presentation/
│   ├── Home/           HomeViewModel, Model/ (ConsolesContent, ConsoleStatus,
│   │                   ConsolePowerControl, ConsoleCover, PowerProblem), Presentation/
│   ├── Library/        LibraryViewModel, GameDetailViewModel, Model/ (LibraryShelf,
│   │                   LibraryPlaceholder, GameFact, GameInput, FavoriteAction), Presentation/
│   ├── Settings/       SettingsViewModel, SessionControlling, Model/ (AccountChoice),
│   │                   Presentation/
│   └── Stream/         StreamViewModel, StreamPlatform, PictureCapabilities, StreamOverlays,
│                       StreamDependencies, Model/ (StreamStatus, StatisticsReadout,
│                       DialogButton, SharpeningLevel, …), Presentation/
├── Services/           AccountService, ConsoleService, CloudLibraryService, StreamService,
│                       StreamConnection, SignedInAccount and their Live… implementations;
│                       Preferences, FavoritesStore, LibraryCache
├── Model/              the values the services and storage exchange: AccountSummary,
│                       CloudLibrary, CloudAccess, HomeSnapshot, LibrarySnapshot, GameSort,
│                       SoundStage, LoadState
├── Logging/            LogCategory, the Logger initializer that takes one
├── UserInterface/
│   ├── Colors/         Palette, PaletteID, RGBColor, PalettePresentation, semantic colours
│   │                   (ShapeStyleExtensions)
│   ├── Dimensions/     the spacing, corner and shadow scales, shared sizes
│   ├── Buttons/        PrimaryButtonStyle, PrimaryButtonSize, CircleIconButtonStyle, their
│   │                   leading-dot ButtonStyleExtensions
│   ├── Modifiers/      AppPalette, CardSurface, Shimmer
│   ├── Components/     StatusDot, ClockView, PalettePicker
│   ├── Backgrounds/    SkyBackground, its sky values and its shader
│   └── Extensions/     View, EnvironmentValues, BundleDescription extensions
└── Resources/          Localizable.xcstrings, PrivacyInfo.xcprivacy
```

- StarfoldShared is everything the three apps share: each feature's ViewModel, the services a
  ViewModel reaches the outside world through, the storage it saves to, the values those
  exchange, and the interface pieces every platform's views use.
- `Features/` has the same five folders as each app's `Features/`. A feature's folder holds its
  ViewModel at the top, the values it shows (`Model/`) and their display text
  (`Presentation/`).
- A value lives in the top-level `Model/` when a service or storage signature needs it or
  several features share it; a value one feature alone shows lives in that feature's `Model/`.
- `AppViewModel` is the root ViewModel: who is signed in, the accounts, and the ViewModels of the
  signed-in account and the current stream. Each app creates exactly one, through
  `AppDependencies(streamPlatform: StreamPlatform()).makeAppViewModel()`, and puts it in the
  environment.
- `HomeViewModel` and `LibraryViewModel` belong to one account; switching accounts replaces them.
- `StreamViewModel` belongs to one stream; a restart replaces it.
- No singletons, `shared` instances or service locators.

## The packages

StarfoldShared is laid out by layer, with one folder per feature ([above](#starfoldshared)).
XboxKit and StreamKit are grouped by domain, one folder per part of the protocol or pipeline. A
package's root holds only folders.

```text
StarfoldShared/Sources/TopShelfKit/
                 TopShelfSnapshot, TopShelfItem, TopShelfLink, TopShelfStore: what the Apple TV
                 app writes to the App Group and the extension reads

XboxKit/Sources/XboxKit/
├── Auth/        device-code sign-in, Microsoft and Xbox Live tokens, accounts
├── HTTP/        HTTPClient, XboxHTTPError, date parsing
├── Library/     profile, consoles, the cloud catalogue
├── Storage/     the keychain and its in-memory stand-in
└── Streaming/   the session REST API: start, provisioning, SDP and ICE exchange

StreamKit/Sources/StreamKit/
├── Session/     StreamController and its public values: target, options, phase, updates
├── Connection/  the peer connection, data channels, ICE gathering, decoder factory
├── Protocol/    the bytes and messages on the data channels
├── Input/       controllers, keyboard, rumble and the input sender
├── Audio/       the stereo audio devices for Mac and the other platforms
├── Rendering/   frame queue, Metal enhancement, frame pacing, the system video layer
├── Quality/     quality choice and adaptive quality
├── Statistics/  WebRTC statistics, network diagnostics, the copyable report
└── Logging/     log categories
```

- A type with more than one job is split by job, not by size: `StreamController` drives the
  session's lifecycle, `HostChannels` speaks the data-channel protocol (handshake, dialogs,
  input events) as pure values the controller performs, `StatisticsCollector` turns WebRTC reports into `StreamStatistics`,
  `CandidateGathering` decides when local candidates are complete; `StreamRenderer` queues frames,
  `FrameEnhancer` runs the Metal passes, `OutputBufferPool` and `IntermediateTextures` own their
  buffers.
- A folder exists only once it has a file. No `Shared/`, `Helpers/`, `Utils/` or `Managers/`.
