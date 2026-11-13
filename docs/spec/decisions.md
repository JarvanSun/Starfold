# Decisions

Reasons no name can carry (an OS bug, a measured timing, a protocol quirk, a deliberate choice),
one line under the type they explain. Protocol facts are in [streaming.md](streaming.md). When the
reason goes away, the line goes with it.

## Sign-in, tokens and Xbox services

In XboxKit.

- **XboxDateParser**: Xbox Live sends seven fractional digits, which `Date.ISO8601FormatStyle` rejects, so the parser trims them to milliseconds, then falls back to no fraction.
- **HTTPClient**: It is an actor only to keep the session and decoder in one isolation domain; `Request.timeout` overrides URLSession's 60 s default for requests the user waits on.
- **KeychainStore**: The Mac uses its sandboxed login keychain because the data-protection keychain needs a provisioned keychain-access-groups entitlement (else errSecMissingEntitlement, -34018).
- **DeviceCodePrompt**: `verificationURLComplete` falls back to Microsoft's link page with the code as `otc`, which skips code entry; the QR code and Open Link open it.
- **FormBody**: Everything but RFC 3986 unreserved characters is escaped because URLComponents leaves `+`, which token endpoints read as a space.
- **URL**: `init(upgradingXboxImageToHTTPS:)` rewrites `http://images-eds.xboxlive.com` gamerpics to `images-eds-ssl.xboxlive.com`, since App Transport Security blocks HTTP.
- **XboxLiveClient**: Presence lists the dashboard (title 750323071) like a game, so it is skipped; device type "Scarlett" is Xbox Series X|S, "XboxOne" the older family.
- **Console**: `id` is gssv's `serverId`; only `on` and `connectedStandby` are reachable, because a fully off console cannot wake when a session starts.
- **CatalogClient**: The service sometimes fails a whole batch with 5xx, so a failed batch is retried once, then split in half, and the call throws only when nothing was fetched.
- **CatalogProduct**: Store image URLs are protocol-relative and get `https:` prepended.
- **GSSVSession**: On tvOS `stop()` logs the DELETE outcome under `TVSessionCleanup` for the Apple TV background cleanup; with KeychainStore's, it is XboxKit's only `#if os`.
- **CloudTitle**: It decodes a missing `touchBundleIDs` as empty so library caches written before touch support still load.
- **ZipArchive**: Hand-written because Apple platforms have no public unzip API and the app takes no third-party dependency besides WebRTC; Compression's `COMPRESSION_ZLIB` is raw DEFLATE (RFC 1951), which is exactly zip method 8.
- **ZipArchive**: It reads entries through the central directory, so local headers with data descriptors (sizes written after the data) are read correctly; an entry over 64 MB is refused so a forged size cannot exhaust memory.
- **TouchJSONDecoder**: The Touch Adaptation Kit's own sample bundles save every JSON file with a UTF-8 byte-order mark, which is skipped before decoding.
- **TouchLayout**: `$ref`s may point into `context.json` state, which the game patches at runtime, so a layout keeps its JSON and is resolved and decoded again for each context.
- **TouchControlKind**: A control whose type is unknown, or whose fields do not decode, becomes `unsupported` instead of failing the layout, because newer layout schema versions add controls and fields.

## The stream

In StreamKit.

- **Package.swift**: webrtc-xcframework is pinned by revision because tag 150.7871.02 is not valid semver.
- **StreamRuntime**: One per app, created by AppDependencies; it builds the WebRTC factory lazily so field trials and SSL set-up run only when the first stream starts.
- **StreamRuntime**: On iOS-family platforms the NWPathMonitor field trial is set before any other WebRTC call, because a factory with its own audio device skips the built-in network filter.
- **StreamRuntime**: LKRTCInitializeSSL runs once per process before any connection, or DTLS fails.
- **StreamRuntime**: The Mac uses MacStereoAudioDevice because WebRTC's legacy CoreAudio module pulls in bursts and inflates the jitter buffer.
- **PeerConnection**: It holds DelegateProxy strongly because WebRTC holds delegates weakly; without it the stream sits at Connecting forever.
- **PeerConnection**: Link-local networks are off because ICE checks over awdl0 / llw0 wake AWDL, which takes the radio off channel for tens of milliseconds.
- **PeerConnection**: Fast jitter-buffer accelerate is on because game audio is rarely quiet enough for NetEq to stretch (measured: 200 vs 120 ms on the Mac after a hiccup).
- **PeerConnection**: Swift imports setCodecPreferences:error: with a placeholder `error: ()` label to tell it from the deprecated overload.
- **StreamController**: The selected candidate pair is the one transport stats name, because an IPv4 and an IPv6 pair can both be nominated.
- **StreamController**: The slot-0 reset-then-announce pair runs in its own task so its 500 ms gap does not hold up other messages, and the input sender starts only after it.
- **InputSender**: Input goes out on its own thread so a press never waits for an actor hop and timers cannot coalesce the 8 ms wake-up.
- **InputState**: A Guide pulse rides on its slot even with no controller connected.
- **GamepadRouter**: Deliveries happen under the lock in change order so an older state never overtakes a newer one; destinations only record and wake the input thread.
- **GamepadRouter**: Slot 0 always gets a state because the host is told about it at connect, and each stream starts with no keyboard keys held.
- **GamepadRouter**: Clearing pending input on TV delivers nil even for slot 0, so the sender drops latched taps before neutral states follow.
- **ControllerHub**: `GCController.shouldMonitorBackgroundEvents` stays on so input arrives when the stream window is not key.
- **ControllerHub**: Connect and disconnect notifications only trigger a diff against `GCController.controllers()`, keeping non-Sendable controllers out of main-actor closures.
- **ControllerHub**: A new controller's first state goes through the handler queue to stay ordered with its own callbacks and a later disconnect.
- **ControllerInputDestination**: Direct routing disables the system gesture on Home, Menu and Options so the Xbox / PS button reaches the game; on TV, TVControllerInput toggles it with gameplay.
- **RumblePlayer**: It uses the standard pattern player because on macOS 27 an advanced player's events are rejected by gamecontrollerd and silence later rumble; a stopped engine is restarted and retried once.
- **TVControllerInput**: All TV filtering runs on the controller queue; main-actor commands join it rather than add a hop to each input.
- **TVControllerInput**: UIKit may consume button releases while it has focus, so the held-control barrier is refreshed from the gamepads before gameplay resumes.
- **TVGamepadPolicy**: Leaving gameplay sends neutral for every player and quarantines held controls until their physical release.
- **TVGamepadPolicy**: A removed controller is reported only as a removal, because a neutral pad first would re-add the slot.
- **KeyboardGamepad**: Key codes are hardware positions (`kVK_*`) so WASD stays under the left hand on every layout.
- **StreamRenderer**: Every frame is rendered in order, since dropping burst frames would undo pacing; only a backlog over 6 frames drops the oldest.
- **StreamRenderer**: At most 12 output buffers live (the layer holds about 8 at 60 fps plus one drawing); past that a frame is dropped, since a 5K buffer is about 59 MB.
- **StreamRenderer**: Enhanced frames are paced from the moment they are ready, so render time is part of the measured transit.
- **StreamRenderer**: `clear()` empties the video layer on the render queue, after any frame being drawn, so that frame cannot reappear.
- **StreamRenderer**: CoreVideo textures behind a frame's Metal textures are kept alive until the command buffer completes.
- **StreamRenderer**: Output keeps the source's primaries and transfer function (BT.709 by default); tone-mapped output is half-float BT.2020 PQ, because 8-bit would band.
- **StreamRenderer**: The kept last frame holds one decoder buffer; the platform decides whether to keep it.
- **SystemVideoPresenter**: The layer's sample-buffer renderer is taken once on the main actor and fed from a background thread, which it supports.
- **SystemVideoPresenter**: Changing pacing mode mid-stream adjusts the existing pacer, because a new one would schedule frames before ones already queued.
- **FramePacer**: A frame is shown at capture time + transit floor (lowest transit per second over 10 s) + a delay covering recent lateness that rises at once and decays slowly; a late frame is shown at once.
- **VideoColorConversion**: The matrix layout matches the shader (column-major 3x3, 16-byte-aligned offset); 10-bit samples sit in the top bits of 16-bit words; untagged frames are BT.709.
- **StreamShaders.metal**: Tone mapping keeps SDR white at 203 nits (BT.2408) and lifts highlights towards 600 nits; sharpening is a contrast-adaptive variant that sharpens less where contrast is high.
- **AdaptiveQuality**: The Xbox lowers resolution itself when bandwidth runs short (measured: 1080p at 3 Mbps went to 720p60 after 9 s), so Automatic asks for 1080p and only explains.
- **AdaptiveQuality**: Cloud 1440p without Game Pass starts the session and ends it at once (measured with Fortnite), so such streams are pinned to 1080p.
- **StatisticsReport**: Labels are fixed English because the report is read by whoever receives it and compared across runs.
- **ControlMessage**: JSON keys are sorted only for deterministic tests; the host ignores order.
- **PictureGeometry**: Upscaling renders at the picture's on-screen pixel size (never below the stream's); without upscaling the stream's size is used, since the layer scales anyway.
- **StreamViewModel**: It watches `Preferences` with `withObservationTracking`, so a change from Settings, the menu bar or the stream controls applies the same way, until the stream ends.
- **StreamViewModel**: The sharpening menu shows the nearest of four levels, because Settings saves any slider strength.
- **StreamFailureAdvice**: An unrecognized host message goes through `stream.advice.unrecognized %@`, so every advice is a `LocalizedStringResource`.

## Shared app

In StarfoldShared.

- **HomeViewModel, LibraryViewModel**: `onPlay`, `onRefreshAccount` and `onSignInRequired` are set by `AppViewModel` after creation to keep each initializer to the four values that make it testable alone.
- **CloudAccessPresentation**: The cloud card keeps an empty subtitle line while access is unknown so it does not change height.
- **AppViewModel**: Play on a stream already starting or playing does nothing, because restarting it trips the host's duplicate-session check (HTTP 409).
- **AppViewModel**: A console stream's last frame is taken before `stop()`, which clears the renderer.
- **AppViewModel**: `streamHome` is weak so a last frame taken after switching accounts or signing out is dropped, not saved to another account.
- **AppViewModel**: `endStream()` clears `stream` only if it is still the one stopping, because a new one may have started.
- **AppViewModel**: The console refresh loop follows the app-wide scene phase, because a loop owned by a view stopped after an alert.
- **HomeViewModel**: Presence does not say which console runs a game, so it is credited to the first console that is on.
- **ConsoleCover**: A console's own last frame wins over "playing now", because Xbox keeps reporting the game for a while after the stream ends.
- **LiveCloudLibraryService**: Cloud access is derived from the playable titles, because the Game Pass offering also answers for lapsed or lower-tier accounts.
- **LibraryCache**: The saved library is only a cache; last frames stay on the device because they can show private messages.
- **SignInViewModel**: `shouldClose` turns true 0.9 s after signing in so the Add Account sheet shows success first; the welcome screen ignores it.
- **SignInCode**: The address reads "microsoft.com/link", easier to read and type than the full URL.
- **WelcomeFeature**: The list is shared but each app words it in its own `WelcomeFeaturePresentation`; only cloud gaming reads the same everywhere (`WelcomeCopy`).
- **SettingsViewModel**: `session` is set after creation, weakly, because `AppViewModel` owns Settings and hands itself over as `SessionControlling` once both exist.
- **QualityChoice**: "720p" and "1080p" are keys too, so every case presents as `LocalizedStringResource`.
- **StreamViewModel**: The first host rumble is logged once per stream to tell "the game sent none" from "it did not play".
- **LiveAccountService**: It keeps each account's `XboxAccount` by xuid, because the actor holds the cached tokens and re-reading the store would refresh them per request.
- **Palette**: Nebula matches the app icon's #6652E8; Sunrise keeps the original pre-palette values, including the 85 % black label and coral glow.
- **PrimaryButtonStyle**: Under Reduce Motion the hover growth is dropped; the hover lightening stays.
- **AppPalette**: Apple TV uses `untintedAppPalette()` because there the palette only colours the sky.

## Mac

In `StarfoldMac/`.

- **AppDelegate**: A running stream ends in `applicationShouldTerminate`, waiting at most 2 s, because `onDisappear` tasks never run at termination and the host session would stay reserved.
- **MenuBarMenu**: It is a standard menu because the custom panel it replaced did not bring the windows it opened to the front.
- **MenuBarMenu**: Console items are always enabled because the reported power state lags about a minute; starting a stream says when the console is off.
- **StreamWindowOpener**: Starting a stream activates the app, or from the menu bar the window opens behind other apps.
- **ProfileBadge**: The gamerpic loads at original size because the service rejects size parameters with HTTP 400.
- **MainWindowView**: The window keeps the app name, though no title is visible, for the Window menu and Mission Control.
- **MainWindowView**: Each pushed page brings its own SkyBackground because NavigationStack pages are opaque.
- **MainToolbar**: The account menu shows only when signed in, because signed out a second sign-in would request a second code.
- **MainToolbar**: A flexible ToolbarSpacer keeps the clock and settings trailing once the title is removed.
- **HomeCard**: The primary button has words because a lone chevron did not say it opens the library; it is compact to sit level with the round buttons.
- **WelcomeView**: The sign-in task hangs off the GeometryReader so resizing between layouts never restarts it and replaces the code.
- **SignInHostView**: It creates the `SignInViewModel` in `onAppear`, not `task`, so the sheet opens at its final size, holding a clear view until then.
- **GamepadButton**: A, B, X, Y, LB and RB are catalog keys so every button name is one `LocalizedStringResource`.
- **SettingsView**: Settings stay neutral because macOS draws the selected toolbar tab from the asset accent, which cannot follow a palette.
- **StreamView**: Only the black background runs under the title bar, so the game's HUD and the statistics are never hidden.
- **StreamView**: Every held key is released when the window stops being key, because releases elsewhere never reach it.
- **StreamView**: `isFullScreen` lives here because the control bar is rebuilt each time it reappears.
- **StreamStatusView**: The artwork is a background, not a stack sibling, so its fill size cannot push the centred content off-centre; the blur is opaque to avoid a grey halo.
- **FullScreenObserverView**: Full-screen notifications cover every way in and out; the first report is deferred because `viewDidMoveToWindow` runs inside SwiftUI's update.
- **StatisticsReadout**: The stream's own size stays on its own row above the upscaled size, because what shows as 4K is upscaled.
- **StreamStatisticsView**: The panel is `fixedSize` so the latency divider does not stretch it across the window.
- **StreamVideoHostView**: A display link asks for 120 Hz on high-refresh screens so a 60 fps frame waits 4.2 ms for a refresh on average instead of 8.3 ms.
- **StreamKeyboardMonitor**: Keys come from a local event monitor so they reach the stream while overlay controls have focus; Command shortcuts pass to the menu bar.
- **StreamPictureInPicture**: It is a floating panel holding the stream's own layer, not AVPictureInPictureController, because on macOS 27 the system window cropped a sample-buffer layer.
- **StreamPictureInPicture**: While the picture floats, controllers are monitored in the background because the player is likely in another app.
- **StreamPictureInPicture**: `dismiss()` removes the panel without touching the window (another stream is starting); `stop()` returns to the window so its end page can speak.
- **PictureInPictureView**: MetalFX upscales to the panel's pixels, not the hidden window's.

## Apple Vision Pro

In `StarfoldVision/`.

- **StreamView**: The control ornament is anchored at the scene's bottom with top alignment, because the default bottom ornament overlapped the picture.
- **StreamView**: The black fill sits only behind the picture; the waiting screen is glass with its own corners.
- **StreamStatusView**: The artwork is a background so its fill size cannot push the centred content off-centre; the view fills the window so connecting matches the picture's size.
- **VideoHostView**: A GCEventInteraction claims the controller for the game, because visionOS otherwise turns buttons into pinches.
- **VideoHostView**: The window scene resizes only uniformly so the picture fills it without black bars.
- **ConsoleCard, GameHero, SignInCodeStep**: Play and Sign In use an HStack centred on the icon, because a Label set the words below the glyph's middle.
- **GameDetailView**: The title display mode is inline because the name is already large on the art.

## Apple TV

In `StarfoldTV/`, TopShelfKit and `StarfoldTopShelf/`.

- **RootView**: It sets `AppViewModel.onPlayRequest` to `StreamPresenter`, which asks for a controller and owns the full-screen cover; otherwise a stream would start with nothing showing it.
- **LibraryView, SearchResultsView**: The search text lives in `LibraryViewModel`, so the Cloud Gaming tab reads only lists the search does not change and shows its library on `noResults`.
- **RootView**: A Top Shelf link arriving while the account restores waits in `pendingLink`.
- **LibraryHostView**: RootView owns the library's navigation path so a Top Shelf link can open a game.
- **SettingsHostView**: The settings root has no title because the selected tab names it.
- **ConsoleCard**: The artwork alone shows the last game, with no caption; the model name shows only without activity.
- **StreamPresenter**: Ending waits for a cancelled start, so an old token request can never open a session after returning to the library.
- **StreamPresenter**: `end(presentationID:)` ignores a dismissal from an earlier presentation, which may arrive after a retry.
- **StreamPresenter**: Any explicit end bumps `restartRequest` so a restart waiting for cleanup is dropped.
- **StreamPresenter**: `goBack()` closes the control menu when open, because the menu is a system sheet that would otherwise handle its own Back, and ends the stream otherwise.
- **StreamPresenter**: Raw controller input reaches the game only while the picture shows with nothing over it, the app is in front and a controller is connected; otherwise the remote keeps focus.
- **StreamHost**: A GCEventViewController owns event routing for the whole stream subtree, its SwiftUI controls included.
- **StreamEventViewController**: Remote handlers leave system gestures on so a long Back and the TV button still go Home.
- **StreamEventViewController**: Back and Play/Pause act on release so restoring focus cannot consume the same press again.
- **StreamEventViewController**: The Siri Remote's Play/Pause is `microGamepad.buttonX`.
- **PreviewObjectPool**: The preview system dialogs equal what MessageChannel parses from ShowMessageDialog / ShowVirtualKeyboard.
- **ContentProvider**: It runs on the extension's own queue and touches no UI, so it is nonisolated; nil shows the static image.
- **TopShelfSnapshot**: Section titles arrive localized so the extension carries no strings.
- **TopShelfSnapshot**: `init?(app:)` is nil while restoring so a relaunch does not blank the Top Shelf.
- **TopShelfSnapshot**: Game items prefer wide art with the title logo so a row of pictures says which game each is.
- **TopShelfSnapshot**: `rowItemLimit` is 10, enough to span the screen; more is never visible without scrolling.
- **TopShelfStore**: `save(_:)` returns whether the snapshot changed, so callers nudge the system only then.
