# Architecture

What every platform shares (accounts, library, stream, settings, palette) is written once in the
packages; what a person sees and touches is written per platform.

- macOS 26, visionOS 26, tvOS 26, and iOS 26 on iPhone and iPad, or later.
- Swift 6 language mode, Swift tools 6.2, Xcode 26. SwiftUI and Observation only. MVVM.
- No backend of our own, no analytics, no third-party SDK except WebRTC.

## Modules

![Modules: four platform apps over StarfoldShared, which uses XboxKit and StreamKit](images/modules.svg)

```text
Starfold.xcodeproj
├── Configuration/          Starfold.xcconfig: bundle identifier, App Group, Microsoft client ID;
│                           an optional, git-ignored Local.xcconfig overrides them and sets the team
├── StarfoldMac/            the Mac app: entry point, its views of every feature, navigation,
│                           AppKit bridges
├── StarfoldVision/         the Vision Pro app, same shape
├── StarfoldTV/             the Apple TV app, same shape
├── StarfoldiOS/            the iPhone and iPad app, same shape
├── StarfoldTopShelf/       the Apple TV Top Shelf extension
├── StarfoldTVTests/        tests of the Apple TV app's own code, hosted by the Apple TV app
├── Preview Content/        PreviewObjectPool and its preview services, compiled into the three
│                           apps as Development Assets
└── Packages/
    ├── StarfoldShared      every feature's ViewModel and values, services, storage, shared
    │                       interface pieces; and TopShelfKit, the Top Shelf snapshot
    ├── XboxKit             sign-in, tokens, profile, consoles, cloud catalogue, session REST API
    └── StreamKit           WebRTC, data channels, input, rendering, frame pacing, quality
```

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

```text
StarfoldMac/
├── StarfoldMacApp.swift  the entry point: its scenes
├── Features/
│   ├── SignIn/           SignInView, WelcomeView, Components/, Presentation/
│   ├── Home/             HomeView, Components/, Model/
│   ├── Library/          LibraryView, GameDetailView, Components/
│   ├── Settings/         SettingsView and its tabs, Components/, Presentation/
│   └── Stream/           StreamView, Components/
├── Navigation/           MainWindowView, HomeRoute, MainToolbar, AccountMenu, StreamWindowView,
│                         SignInHostView, …
├── Platform/             AppKit bridges (Video/, Keyboard/, PictureInPicture/, FullScreen/),
│                         AppDelegate, StreamPlatformOnMac
├── UserInterface/        Buttons/, Modifiers/, Components/, Dimensions/ (DimensionsOnMac)
├── Resources/            Assets.xcassets, AppIcon.icon, Localizable.xcstrings, PrivacyInfo
└── Configuration/        Info.plist, StarfoldMac.entitlements
```

- A feature folder holds that platform's main View(s) at the top, views only it uses in
  `Components/`, and `Model/` and `Presentation/` only for values and wording that platform alone
  uses (`HomeCardStatus`).
- Views have no platform prefix: `HomeView` is a different type in each app.
- Beside `Features/`: `Navigation/` (how pages are reached), `Platform/` (wrapped system APIs,
  grouped by the feature they serve) and `UserInterface/`.
- `StarfoldVision/` and `StarfoldTV/` have the same shape. Their `Navigation/` holds `RootView`
  and a `…HostView` per tab (Apple TV's Search results view lives in `Features/Library/`);
  `StarfoldTV/Platform/` also holds `Controller/`, `TopShelf/` and `Background/`.
- `StarfoldiOS/` has the same shape, with Vision Pro's `RootView` and `…HostView`s. Its
  `Platform/` holds `Touch/` (the Touch Controller overlay: drawing, touches, turning a
  `TouchControlPlan` into controls), `Video/`, `Keyboard/` (`GCKeyCode` to `KeyboardKey`),
  `Orientation/` (landscape while an iPhone streams) and `Background/` (ending the session on
  leaving the app). Which controls a layout has and where they go is decided in StarfoldShared
  (`TouchLayoutPlanner`), so it is tested on macOS.

## StarfoldShared

```text
StarfoldShared/Sources/StarfoldShared/
├── App/                AppViewModel, AppDependencies (the composition root), AppInfo, SceneID;
│                       Model/ (SessionState)
├── Features/
│   ├── SignIn/         SignInViewModel, SigningIn, Model/, Presentation/
│   ├── Home/           HomeViewModel, Model/ (ConsolesContent, ConsoleCover, …), Presentation/
│   ├── Library/        LibraryViewModel, GameDetailViewModel, Model/, Presentation/
│   ├── Settings/       SettingsViewModel, SessionControlling, Model/, Presentation/
│   └── Stream/         StreamViewModel, SystemDialogsViewModel, StreamPlatform, StreamOverlays,
│                       Model/, Presentation/
├── Services/           AccountService, ConsoleService, CloudLibraryService, StreamService and
│                       their Live… implementations; Preferences, FavoritesStore, LibraryCache
├── Model/              values the services and storage exchange (CloudLibrary, LoadState, …)
├── Logging/            LogCategory, Logger(category:)
├── UserInterface/
│   ├── Colors/         Palette, PaletteID, semantic colours
│   ├── Dimensions/     spacing, corner and shadow scales, shared sizes
│   ├── Buttons/        PrimaryButtonStyle, CircleIconButtonStyle, ButtonStyleExtensions
│   ├── Modifiers/      AppPalette, CardSurface, Shimmer
│   ├── Components/     StatusDot, ClockView, PalettePicker
│   ├── Backgrounds/    SkyBackground and its shader
│   └── Extensions/     View, EnvironmentValues, BundleDescription extensions
└── Resources/          Localizable.xcstrings, PrivacyInfo.xcprivacy
```

- A feature folder holds its ViewModel at the top, the values it shows (`Model/`) and their
  display text (`Presentation/`).
- A value lives in the top-level `Model/` when a service or storage signature needs it or several
  features share it; otherwise in its feature's `Model/`.
- Each app creates exactly one `AppViewModel`, through
  `AppDependencies(streamPlatform: StreamPlatform()).makeAppViewModel()`, and puts it in the
  environment.
- No singletons, `shared` instances or service locators.

## The packages

XboxKit and StreamKit are grouped by domain. A package's root holds only folders.

```text
StarfoldShared/Sources/TopShelfKit/
                 TopShelfSnapshot, TopShelfItem, TopShelfLink, TopShelfStore

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
├── Audio/       the stereo audio devices
├── Rendering/   frame queue, Metal enhancement, frame pacing, the system video layer
├── Quality/     quality choice and adaptive quality
├── Statistics/  WebRTC statistics, network diagnostics, the copyable report
└── Logging/     log categories
```

A type with more than one job is split by job, not by size: `StreamController` drives the
lifecycle, `HostChannels` decides the data-channel conversation as pure values the controller
performs.
