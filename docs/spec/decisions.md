# Decisions

Why code is the way it is when no name can say it: an OS bug, a measured timing, a protocol
quirk, a deliberate choice. One bullet per decision, under the type it explains; protocol facts
are in [streaming.md](streaming.md). When the reason goes, the bullet goes.

## Sign-in, tokens and Xbox services

In XboxKit.

- **DeviceCodeFlow**: A dropped connection, timeout or lost network is retried once at once, then
  left to the next poll. Sign-in happens in a browser, often on the same device, and iOS closes a
  suspended app's connections, so the first request back fails with `networkConnectionLost`;
  URLSession retries only idempotent requests, and these are POSTs.
- **KeychainStore**: The Mac uses its sandboxed login keychain; the data-protection keychain needs
  a provisioned keychain-access-groups entitlement (else errSecMissingEntitlement, -34018).
- **URL**: `init(upgradingXboxImageToHTTPS:)` moves `http://images-eds.xboxlive.com` gamerpics to
  `images-eds-ssl.xboxlive.com`, because App Transport Security blocks HTTP.
- **XboxLiveClient**: Presence lists the dashboard (title 750323071) like a game, so it is
  skipped. Device type "Scarlett" is Xbox Series X|S, "XboxOne" the older family.
- **Console**: `id` is gssv's `serverId`. Only `on` and `connectedStandby` are reachable: a fully
  off console cannot wake when a session starts.
- **CatalogClient**: The service sometimes fails a whole batch with 5xx, so a failed batch is
  retried once, then split in half; the call throws only if nothing was fetched.
- **GSSVSession**: On tvOS `stop()` logs the DELETE outcome under `TVSessionCleanup` for the Apple
  TV background cleanup; with KeychainStore's, it is XboxKit's only `#if os`.
- **CloudTitle**: A missing `touchBundleIDs` decodes as empty, so caches saved before touch
  support still load.
- **GSSVClient**, **TitleInputConfiguration**: A `supportedTabs` entry without an `id` is skipped,
  so one malformed touch bundle cannot fail the cloud library on every platform.
- **ZipArchive**: Hand-written: Apple platforms have no public unzip API and the app takes no
  dependency but WebRTC. Compression's `COMPRESSION_ZLIB` is raw DEFLATE (RFC 1951), which is zip
  method 8.
- **ZipArchive**: Entries are read through the central directory, so data descriptors (sizes
  after the data) work; an entry over 64 MB is refused, so a forged size cannot exhaust memory.
- **TouchJSONDecoder**: The Touch Adaptation Kit's own samples save every JSON file with a UTF-8
  byte-order mark, which is skipped.
- **TouchLayout**: `$ref`s may point into `context.json` state, which the game patches at runtime,
  so the bundle keeps each layout's JSON and decodes it again for each context.
- **TouchControlKind**: A control of unknown type, or whose fields fail to decode, becomes
  `unsupported` rather than failing the layout, because newer schema versions add both.

## The stream

In StreamKit.

- **Package.swift**: webrtc-xcframework is pinned by revision; tag 150.7871.02 is not semver.
- **StreamRuntime**: One per app, from AppDependencies; the WebRTC factory is built on the first
  stream, so field trials and SSL set-up wait until then. On iOS-family platforms the
  NWPathMonitor field trial comes before any other WebRTC call, because a factory with its own
  audio device skips the built-in network filter. LKRTCInitializeSSL runs once before any
  connection, or DTLS fails.
- **StreamRuntime**: The Mac uses MacStereoAudioDevice; WebRTC's legacy CoreAudio module pulls in
  bursts and inflates the jitter buffer.
- **PeerConnection**: It holds DelegateProxy strongly, because WebRTC holds delegates weakly;
  otherwise the stream sits at Connecting forever.
- **PeerConnection**: Link-local networks are off: ICE checks over awdl0 / llw0 wake AWDL, which
  takes the radio off channel for tens of milliseconds.
- **PeerConnection**: Fast jitter-buffer accelerate is on, because game audio is rarely quiet
  enough for NetEq to stretch (measured on the Mac after a hiccup: 200 vs 120 ms).
- **PeerConnection**: Swift imports setCodecPreferences:error: with a placeholder `error: ()` label
  to tell it from the deprecated overload.
- **StatisticsCollector**: The selected candidate pair is the one the transport stats name; an
  IPv4 and an IPv6 pair can both be nominated.
- **StreamController**: The slot-0 reset-then-announce pair runs in its own task, so its 500 ms
  gap holds up no other message; the input sender starts only after it.
- **InputSender**: Input goes out on its own thread, so a press never waits for an actor hop and
  timers cannot coalesce the 8 ms wake-up.
- **InputState**: A Guide pulse rides on its slot even with no controller connected.
- **InputState**: A press latched between two samples takes the physicality of the state sent
  with it, so a touch tap shorter than one send round reports as physical.
- **GamepadRouter**: Deliveries run under the lock in change order, so an older state never
  overtakes a newer one; destinations only record and wake the input thread.
- **GamepadRouter**: Slot 0 always gets a state, because the host is told about it at connect;
  each stream starts with no keys held.
- **GamepadRouter**: Under gated routing, clearing pending input delivers nil even for slot 0, so
  the sender drops latched taps before the neutral states that follow.
- **GamepadRouter**: Under gated routing, player one exists only while a controller, the touch
  controller or held keys feed it, so Apple TV still reports a disconnected player one as a
  removal; the keyboard merges in for iPad.
- **ControllerHub**: It turns on `GCController.shouldMonitorBackgroundEvents` for the app's life,
  so input arrives when the stream window is not key or the picture floats over another app.
- **ControllerHub**: Connect and disconnect notifications only trigger a diff against
  `GCController.controllers()`, keeping non-Sendable controllers out of main-actor closures.
- **ControllerHub**: A new controller's first state goes through the handler queue, in order with
  its own callbacks and a later disconnect.
- **ControllerHub**: The touch controller is recognised by the product category the app passes,
  since StreamKit cannot import Touch Controller, and read through `physicalInputProfile`, since
  it may have no `extendedGamepad`.
- **ControllerHub**: The device's own haptics engine starts on the first rumble that needs it, so
  a device that never plays device rumble never starts one.
- **ControllerInputDestination**, **GatedControllerInput**: The system gesture on Home, Menu and
  Options is off (under gated routing, only during gameplay), so the Xbox / PS button reaches the
  game.
- **XboxButtonSettings**: From OS 27 the in-app Home button setting wins over
  `preferredSystemGestureState` unless it is Defer. An app can only read it (while a controller is
  connected) and open its settings screen, so Starfold explains instead of fixing it.
- **RumblePlayer**: It uses the standard pattern player, because on macOS 27 gamecontrollerd
  rejects an advanced player's events and silences later rumble. A stopped engine is restarted
  and retried once.
- **GatedControllerInput**: All gated filtering runs on the controller queue; main-actor commands
  join it rather than add a hop to each input.
- **GatedControllerInput**: UIKit may swallow button releases while it has focus, so the held
  controls are read again from the gamepads and the touch controller before gameplay resumes.
- **GatedGamepadPolicy**: Leaving gameplay sends neutral for every player and quarantines held
  controls until they are physically released.
- **GatedGamepadPolicy**: A removed controller is reported only as a removal; a neutral pad first
  would re-add the slot.
- **GatedGamepadPolicy**: Touch is its own source (`GamepadSource.touch`), so a finger held
  through Control Center or a game dialog is quarantined without blocking the controller sharing
  slot 0.
- **ActiveInputSwitch**: Only a deliberate control (a button, or a stick or trigger at 0.3 or
  more) flips it; a resting stick's drift would hide the touch controls as soon as they are
  touched. A flip hops to the main actor, a sample never does.
- **KeyboardGamepad**: Key codes are hardware positions (`kVK_*`), so WASD stays under the left
  hand on every layout.
- **StreamRenderer**: On the Mac and iOS every frame is rendered in order, since dropping burst
  frames would undo pacing; only a backlog over 6 frames drops the oldest.
- **StreamRenderer**: Enhanced frames are paced from when they are ready, so render time counts
  as transit.
- **StreamRenderer**: `clear()` empties the video layer on the render queue, after any frame being
  drawn, so that frame cannot reappear.
- **StreamRenderer**: The kept last frame holds one decoder buffer; the platform decides whether
  to keep it.
- **OutputBufferPool**: At most 12 output buffers live (the layer holds about 8 at 60 fps, plus one
  being drawn); past that a frame is dropped, since a 5K buffer is about 59 MB.
- **OutputTarget**: Output keeps the source's primaries and transfer function (BT.709 when
  untagged); tone-mapped output is half-float BT.2020 PQ, because 8-bit would band.
- **FrameEnhancer**: The CoreVideo textures behind a frame's Metal textures live until the
  command buffer completes.
- **SystemVideoPresenter**: The layer's sample-buffer renderer is taken once on the main actor and
  fed from a background thread, which it supports.
- **SystemVideoPresenter**: A pacing change mid-stream adjusts the existing pacer; a new one would
  schedule frames before those already queued.
- **FramePacer**: A frame shows at capture time + transit floor (lowest transit per second over
  10 s) + a delay for recent lateness that rises at once and decays slowly; a late frame shows at
  once.
- **VideoColorConversion**: The matrix layout matches the shader (column-major 3x3,
  16-byte-aligned offset); 10-bit samples sit in the top bits of 16-bit words; untagged frames
  are BT.709.
- **StreamShaders.metal**: Tone mapping keeps SDR white at 203 nits (BT.2408) and lifts
  highlights towards 600 nits; sharpening is contrast-adaptive, weaker where contrast is high.
- **AdaptiveQuality**: The Xbox lowers resolution itself when bandwidth runs short (measured:
  1080p at 3 Mbps became 720p60 after 9 s), so Automatic asks for 1080p and only explains.
- **AdaptiveQuality**: Cloud 1440p without Game Pass starts the session and ends it at once
  (measured with Fortnite), so those streams are pinned to 1080p.
- **PictureGeometry**: Upscaling renders at the picture's on-screen pixel size, never below the
  stream's; without upscaling the stream's size is used, since the layer scales anyway.
- **StatisticsReport**: Labels are fixed English, because whoever receives the report reads it
  and compares runs.

## Shared app

In StarfoldShared.

- **HomeViewModel**, **LibraryViewModel**, **SettingsViewModel**: `AppViewModel` sets their `on…`
  closures and Settings' weak `sessionController` after creation. The closures keep each
  initializer to the four values that make it testable alone; `AppViewModel` owns Settings and
  hands itself over as `SessionControlling` once both exist.
- **AppViewModel**: Play on a stream already starting or playing starts no new one; a restart
  trips the host's duplicate-session check (HTTP 409).
- **AppViewModel**: A console stream's last frame is taken before `stop()`, which clears the
  renderer.
- **AppViewModel**: `streamHomeViewModel` is weak, so a last frame taken after switching accounts
  or signing out is dropped, not saved to another account.
- **AppViewModel**: `endStream()` clears `streamViewModel` only if it is still the one stopping;
  a new one may have started.
- **AppViewModel**: The console refresh loop follows the app-wide scene phase; a loop owned by a
  view stopped after an alert.
- **HomeViewModel**: Presence does not say which console runs a game, so the first console that
  is on gets it.
- **ConsoleCover**: A console's own last frame wins over "playing now", because Xbox keeps
  reporting the game for a while after the stream ends.
- **CloudAccessPresentation**: While access is unknown the cloud card keeps an empty subtitle
  line, so its height does not change.
- **LiveCloudLibraryService**: Cloud access comes from the playable titles, because the Game Pass
  offering also answers for lapsed or lower-tier accounts.
- **LibraryCache**: The saved library is only a cache; last frames stay on the device, because
  they can show private messages.
- **LiveAccountService**: It keeps each `XboxAccount` by xuid, because that actor holds the cached
  tokens; reading the store again would refresh them on every request.
- **SignInViewModel**: `shouldClose` turns true 0.9 s after sign-in, so the Add Account sheet
  shows success first; the welcome screen ignores it.
- **QualityChoice**, **GamepadButton**: "720p", "1080p", A, B, X, Y and the bumpers are catalog
  keys though they are not language, so every case presents as a `LocalizedStringResource`.
- **Palette**: Nebula's primary fill is the app icon's #6652E8.
- **WindowTint** (iPhone and iPad, Apple TV, Vision Pro): The accent is the window's `tintColor`,
  not a SwiftUI `.tint`, which also recolours controls the system draws neutral (menu values in a
  Form, glass buttons) and lowered their contrast. These apps set no global accent colour.
- **LiveNetworkPath**: Path updates arrive on the monitor's queue and land on the main actor in
  observable properties, so Settings shows or hides Cellular quality as soon as cellular data
  comes or goes.
- **StatisticsReadout**: The stream's own size has its own row above the upscaled size, because
  what shows as 4K is upscaled.
- **SharpeningLevel**: The sharpening menu shows the nearest of four levels, because Settings
  saves any slider strength.
- **StreamViewModel**: The first host rumble is logged once per stream, to tell "the game sent
  none" from "it did not play".
- **StreamViewModel**: Keys play as a gamepad only while nothing covers the game (no stream menu
  or game dialog); a key arriving otherwise releases every held key, so none sticks.
- **StreamViewModel**: The Cellular quality ceiling caps the quality after the AdaptiveQuality
  override, so a pinned cloud stream still respects it.
- **StreamViewModel**: A title's touch bundle is downloaded once per stream; a failed download is
  retried on a later title message, at most three times, so a broken endpoint is not hit on
  every message.
- **TouchLayoutPlanner**: Microsoft does not publish where its renderer puts TAK slots, so outer
  slots spread evenly over a 100° arc around their wheel, the right wheel running from the top
  towards the centre to match the standard sample's order.
- **TouchControlsViewModel**: A title layout is used only if the planner can draw every visible
  control as the game meant (`TouchLayer.isDrawable`): each has a Touch Controller counterpart,
  no slot holds more than one, the centre wheel is empty, and no button toggles or has a pull
  action. A partly drawn layout could leave out a control the game needs.
- **TouchControlsViewModel**: Each title keeps its own touch state (bundle, context, pending
  patches, layout, hiding), because opening the Xbox Guide moves focus to the shell and back.
  Patches that arrive before a title's bundle apply once it loads; a bundle that arrives after
  focus moved on is kept for its title.
- **TouchControlsViewModel**: A title layout takes only the edited opacity; moves and stick
  settings apply to the standard layout alone, because a title layout's positions are the game's
  design.
- **TouchSticks**: Stick visibility is one setting for both orientations, because whether a game
  needs a stick does not depend on the screen's shape. The plan carries it, so the planner still
  places every stick and the editor can outline a hidden one.
- **Preferences**: Touch layout edits live in an observed property as well as `UserDefaults`, so
  a stream redraws as soon as the editor changes them.
- **TouchBundleUnpacker**: A touch bundle is inflated and checked off the main actor
  (`@concurrent`), because a large bundle arrives while the stream is playing.
- **StandardTouchLayout**: The standard layout is Microsoft's MIT `standard-controller.json`,
  decoded like any title layout, so one planner handles both.

## Mac

In `StarfoldMac/`.

- **AppDelegate**: `applicationShouldTerminate` ends a running stream, waiting at most 2 s,
  because `onDisappear` tasks never run at termination and the host session would stay reserved.
- **StarfoldMac**: Hardened runtime is on in the build settings, so a Developer ID export can be
  notarized as it is; re-signing by hand can silently drop entitlements.
- **StarfoldMac**, **SettingsView**: The app keeps 1.0's grey `AccentColor` asset and leaves the
  Settings window untinted, because what AppKit draws from the asset (alerts, focus rings, the
  selected Settings tab) cannot follow a runtime palette and must never fall back to the system
  accent.
- **MenuBarMenu**: It is a standard menu; the custom panel it replaced did not bring the windows
  it opened to the front.
- **MenuBarMenu**: Console items are always enabled, because the reported power state lags about
  a minute; starting a stream says when the console is off.
- **StreamWindowOpener**: Starting a stream activates the app; from the menu bar the window would
  open behind other apps.
- **ProfileBadge**: The gamerpic loads at original size; the service rejects size parameters with
  HTTP 400.
- **MainWindowView**: The window keeps the app name as its hidden title, for the Window menu and
  Mission Control.
- **MainWindowView**: Each pushed page brings its own SkyBackground, because NavigationStack pages
  are opaque.
- **MainToolbar**: The account menu shows only when signed in; signed out, a second sign-in would
  request a second code.
- **MainToolbar**: A flexible ToolbarSpacer keeps the clock and settings trailing once the title
  is removed.
- **WelcomeView**: The sign-in task hangs off the GeometryReader, so resizing between layouts
  never restarts it and replaces the code.
- **SignInHostView**: It creates the `SignInViewModel` in `onAppear`, not `task`, showing a clear
  view until then, so the sheet opens at its final size.
- **StreamView**: Only the black background and the waiting page run under the title bar, so the
  game's HUD and the statistics are never hidden.
- **StreamView**: Every held key is released when the window stops being key, because releases
  elsewhere never reach it.
- **StreamView**: `isFullScreen` lives here, because the control bar is rebuilt each time it
  reappears.
- **StreamStatusView** (Mac, Vision Pro): The artwork is a background, not a stack sibling, so its
  fill size cannot push the centred content off-centre; its blur is opaque, to avoid a grey halo.
- **FullScreenObserverView**: Full-screen notifications cover every way in and out; the first
  report is deferred, because `viewDidMoveToWindow` runs inside SwiftUI's update.
- **StreamStatisticsView**: The panel is `fixedSize`, so the latency divider cannot stretch it
  across the window.
- **StreamVideoHostView**: A display link asks for 120 Hz on high-refresh screens, so a 60 fps
  frame waits 4.2 ms on average for a refresh instead of 8.3 ms.
- **StreamKeyboardMonitor**: Keys come from a local event monitor, so they reach the stream while
  overlay controls have focus; Command shortcuts pass to the menu bar.
- **StreamPictureInPicture**: It is a floating panel holding the stream's own layer, not
  AVPictureInPictureController, because on macOS 27 the system window cropped a sample-buffer
  layer.
- **StreamPictureInPicture**: `dismiss()` removes the panel and leaves the window alone (another
  stream is starting); `stop()` returns to the window so its end page can speak.
- **PictureInPictureView**: MetalFX upscales to the panel's pixels, not the hidden window's.

## Apple Vision Pro

In `StarfoldVision/`.

- **StreamView**: The control ornament is anchored at the scene's bottom with top alignment; the
  default bottom ornament overlapped the picture.
- **StreamView**: The black fill is only behind the picture; the waiting screen is glass with its
  own corners.
- **StreamStatusView**: It fills the window, so connecting matches the picture's size.
- **VideoHostView**: A GCEventInteraction claims the controller for the game; otherwise visionOS
  turns buttons into pinches.
- **VideoHostView**: The window scene resizes only uniformly, so the picture fills it without
  black bars.
- **ConsoleCard**, **GameHero**, **SignInCodeStep**: Play and Sign In are an HStack centred on the
  icon, because a Label set the words below the glyph's middle.

## Apple TV

In `StarfoldTV/`, TopShelfKit and `StarfoldTopShelf/`.

- **RootView**: It sets `AppViewModel.onPlayRequest` to `StreamPresenter`, which asks for a
  controller and owns the full-screen cover; otherwise a stream would start with nothing showing
  it.
- **RootView**: A Top Shelf link arriving while the account restores waits in `pendingLink`.
- **LibraryHostView**: RootView owns the library's navigation path, so a Top Shelf link can open a
  game.
- **StreamPresenter**: An earlier presentation's work never acts on a later one. Ending waits for
  a cancelled start, so an old token request cannot open a session after returning to the
  library; any explicit end bumps `restartRequest`, dropping a restart that waits for cleanup;
  `end(presentationID:)` ignores a dismissal from an earlier presentation, which may arrive after
  a retry.
- **StreamPresenter**: `goBack()` closes the control menu if open, because the menu is a system
  sheet that would otherwise handle its own Back; otherwise it ends the stream.
- **StreamPresenter**: Raw controller input reaches the game only while the picture shows with
  nothing over it, the app is in front and a controller is connected; otherwise the remote keeps
  focus.
- **StreamHost**: A GCEventViewController owns event routing for the whole stream subtree,
  SwiftUI controls included.
- **StreamEventViewController**: Remote handlers leave system gestures on, so a long Back and the
  TV button still go Home.
- **StreamEventViewController**: Back and Play/Pause act on release, so restoring focus cannot
  consume the same press again. The Siri Remote's Play/Pause is `microGamepad.buttonX`.
- **ContentProvider**: It runs on the extension's own queue and touches no UI, so it is
  nonisolated; nil shows the static image.
- **TopShelfSnapshot**: Section titles arrive localized, so the extension carries no strings.
- **TopShelfSnapshot**: `init?(appViewModel:)` is nil while restoring, so a relaunch does not
  blank the Top Shelf.
- **TopShelfSnapshot**: `rowItemLimit` is 10, enough to span the screen; more is never visible
  without scrolling.

## iPhone and iPad

In `StarfoldiOS/`.

- **OrientationLock**: iPhone streams in landscape, so the lock checks the `.phone` idiom; size
  classes cannot tell an iPhone from an iPad window of the same size. The app delegate reports
  it, since SwiftUI has no supported-orientations API. Landscape is held by a count, so closing
  the touch editor over a stream does not release the stream's landscape.
- **TouchControllerView**: Touches reach Touch Controller by a per-finger index, because it does
  not track `UITouch`. `point(inside:with:)` is true only over a control, so other taps reach the
  stream and its menu handle.
- **TouchControllerView**: A stick's half-screen touch area would take the menu handle's taps, so
  touches at the top centre (`streamMenuHandleZone`) pass through when the control there is a
  stick.
- **TouchControllerView**: A rebuild (a new plan) ends each held finger on the old controls and
  begins it again at the same point on the new ones, so a held stick keeps working and no removed
  button stays pressed.
- **TouchControllerView**: A plan that only moves controls or changes opacity
  (`TouchControlPlan.isRearrangement(of:)`) moves the existing controls and sets the controller's
  `size` again to relayout; rebuilding on every drag step dropped frames.
- **TouchControllerView**: In the layout editor the Metal view presents with the Core Animation
  transaction and draws as soon as a control moves, so controls stay under SwiftUI's drag
  handles; during play it presents on its own clock.
- **VideoHostView**: The picture's view takes no touches, so after a rotation UIKit cannot hand it
  the menu handle's taps; its `GCEventInteraction` gets controller events through the responder
  chain, not hit-testing.
- **TouchControlBuilder**: Sticks take half the screen as their touch area, and Touch Controller
  gives an overlapping touch to the higher `zIndex` (at equal `zIndex`, the control added last),
  so sticks sit on a lower layer than every button.
- **TouchControlBuilder**: A stick set to On Touch uses Touch Controller's `hidesWhenNotPressed`;
  one set to Off is not added, so its half of the screen passes touches to the stream.
- **TouchLayoutEditorView**: The editor draws the real Touch Controller controls, non-interactive,
  under transparent drag handles, so what is edited is exactly what is played.
- **BesideLayout**: It measures the editor's inspector and places it beside the selected control,
  within the screen, so the position comes from layout, not from a measurement fed back into
  state.
- **HomeCard** (Mac), **ConsoleCard**: The card surface goes on before the corner clip; clipped
  first, `.secondary` text could not blend with the material and drew nothing.
- **ConsoleCardArt**: The cover is an overlay, so a `scaledToFill` image cannot widen the card.
- **ConsoleCard**, **GameTile**, **RecentGameTile**, **CloudGamingRow**: Each is `.focusable()`,
  because iOS buttons take keyboard and controller focus only with Full Keyboard Access; without
  it the search field was Cloud Gaming's only focus stop.
- **ConsoleCard**: The card is one `Button` with its power and Play buttons `.focusable(false)`;
  as a focusable container, a controller's A ran its first button (power), not Play.
- **RootView**: The sky's canvas is the root's size plus its safe-area insets; a page's frame
  shrinks with the keyboard, which moved the ribbons and showed a black band as it hid.
- **TouchPlatform**: `maxTouchPoints` 5 is a guess at what a phone browser reports to xbox.com,
  not confirmed against the service.
- **RootView**: In the background the stream is kept in a background task and ended 5 s before
  iOS's allowance runs out: a suspended app can neither keep the session alive nor delete it, and
  a quick trip to another app or Notification Center (which backgrounds the app; Control Center
  does not) should not cost the game. The stream stays on screen as `.leftApp`, so coming back
  offers Try Again.
- **RootView**: The stream ends when its full-screen cover is dismissed, not when the stream view
  disappears, because the touch editor's cover hides the stream without ending it. Both paths go
  through one `BackgroundStreamEnd`, which ignores a second end while one runs.
- **BackgroundStreamEnd**: The allowance is read once a second, because it is still unlimited when
  SwiftUI reports the background phase; the wait is capped at a minute, so a stream never runs
  unseen for long where it stays unlimited (the Simulator).
- **BackgroundStreamEnd**: Coming back cancels only the wait, never an end under way, so
  returning at the deadline cannot cut off the session's `DELETE`.
- **StreamView**: Game input routing is applied again on every appearance, because a full-screen
  cover over the stream (the touch editor) makes the stream view disappear, which turns it off.
- **StereoAudioDevice**: Only on iPhone and iPad is sound muted while the whole app is in the
  background (`UIApplication`, not a scene); visionOS keeps playing and Apple TV ends the stream
  on leaving. The flag clears when the device is terminated, so a stream that ended in the
  background does not start the next one muted.
- **StreamViewModel**: Coming to the foreground asks the Xbox for a keyframe, because the decoder
  may have been reset in the background.
