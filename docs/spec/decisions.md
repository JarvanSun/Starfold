# Decisions

Why the code is the way it is. The code carries no comments, so a reason that no name can carry
(an operating-system bug, a measured timing, a protocol quirk, a design choice that looks odd
without its history) is written here, under the type it explains. When the reason goes away, the
line goes with it.

## Sign-in, tokens and Xbox services

In XboxKit.

- **XboxHTTPError**: The error keeps the server's body text because Xbox and Microsoft services explain most failures (expired token, region not allowed, session limit, an `XErr` or `code` value) only in the body.
- **XboxDateParser**: Xbox Live returns seven fractional digits ("2026-09-28T10:00:00.1234567Z"), which `Date.ISO8601FormatStyle` rejects, so the parser trims the fraction to milliseconds and retries before falling back to a timestamp without fractional seconds.
- **HTTPClient**: The client is an actor only so the session and decoder live in one isolation domain; the real concurrency comes from URLSession, and `Request.timeout` overrides URLSession's 60-second default for requests the user is waiting on.
- **KeychainStore**: On macOS the data-protection keychain needs a keychain-access-groups entitlement backed by a provisioning profile (without it SecItem calls fail with errSecMissingEntitlement, -34018), so the Mac app uses its sandboxed login keychain, whose items stay private to the app.
- **MicrosoftIdentity**: Starfold signs in with the public client that xbox.com's web player and the open-source clients (Greenlight, XStreaming) use for the device-code flow, because the xCloud console-transfer token is only known to work for this client; everything that depends on that choice lives in this type.
- **DeviceCodePrompt**: `verificationURLComplete` is the server's pre-filled link or, when the server sends none, Microsoft's link page with the code as `otc`, which goes straight to sign-in; it is what the QR code and Open Link open.
- **DeviceCodeFlow**: The flow is the OAuth 2.0 device authorization grant (RFC 8628); it polls at the server's interval, adds five seconds on `slow_down`, and ends with `DeviceCodeError.expired` once the code's lifetime has passed.
- **FormBody**: The body escapes everything except RFC 3986 unreserved characters because URLComponents leaves `+` unescaped, which the token endpoints read as a space.
- **StoredAccount**: Only the Microsoft token is essential; the Xbox tokens and streaming tokens are caches that save network round trips on relaunch, and `cloudOffering` remembers which cloud offering (`xgpuweb` or `xgpuwebf2p`) worked last time.
- **XboxAccount**: The account is an actor so concurrent callers (a library refresh and a stream start) share one Microsoft token refresh instead of racing to rotate the same refresh token.
- **XboxAccount**: When the remembered cloud offering stops working (for example after Game Pass lapsed) it is forgotten, so the next attempt probes `xgpuweb` and then `xgpuwebf2p` again.
- **XboxAccount**: The transfer token is fetched fresh for every cloud stream, because the session needs a one-shot Microsoft token when it reaches `ReadyToConnect`.
- **XboxLiveTokenClient**: The gssv relying party `http://gssv.xboxlive.com/` needs its trailing slash, and the streaming login answers 403 `OfferingAccessDenied` when the account cannot use an offering (for example `xgpuweb` without Game Pass Ultimate).
- **XboxLiveTokenClient**: The transfer token is a refresh-token grant against login.live.com with the `PURPOSE_XBOX_CLOUD_CONSOLE_TRANSFER_TOKEN` scope; its access token is posted to the session's `/connect` endpoint.
- **URL**: `init(upgradingXboxImageToHTTPS:)` exists because Xbox Live hands out gamerpics as `http://images-eds.xboxlive.com/...`, which App Transport Security blocks, and the same host serves HTTPS as `images-eds-ssl.xboxlive.com`.
- **XboxLiveClient**: Presence lists the dashboard (title 750323071) like a game, so it is skipped; device type "Scarlett" is Xbox Series X|S and "XboxOne" the older family.
- **XboxLiveClient**: A power command returns once xccs has handed it to the console (`status.errorCode` "OK"); the console lists report the new power state only about a minute later, so this reply is the only prompt confirmation, and the request times out after ten seconds because the player is watching a spinner.
- **Console**: `id` is gssv's `serverId`, which `/v5/sessions/home/play` needs; instant-on standby consoles wake by themselves when a session starts, fully off ones cannot, so only `on` and `connectedStandby` are reachable.
- **CatalogClient**: Product lookups are best effort: the service sometimes answers a whole batch of up to 100 products with HTTP 5xx, so a failed batch is retried once and then split in half, and the call throws only when nothing at all could be fetched.
- **CatalogProduct**: Store image URLs are protocol-relative (`//store-images...`) and get `https:` prepended.
- **StreamQuality**: gssv picks the quality tier from the operating system the client reports in `settings.osName` and `X-MS-Device-Info`: android gives 720p, windows 1080p, and tizen 1080p at a higher bitrate on consoles and 1440p for cloud titles that support it.
- **GSSVClient**: A 401 or 403 refreshes the streaming token and retries once; the WebRTC media path does not depend on the token, only signalling and keepalive do.
- **GSSVSession**: The host usually answers within a second, so polling starts every 100 ms and backs off to once a second for long waits such as a cloud queue (PollingBackoff); an HTTP 204 from an SDP or ICE poll means the answer is not ready yet.
- **GSSVSession**: On tvOS, `stop()` logs the outcome of the DELETE under the `TVSessionCleanup` category because the Apple TV app's background cleanup refers to these logs; with KeychainStore's keychain choice, it is one of XboxKit's two `#if os`.
- **SignalingAnswerParser**: `exchangeResponse` is a JSON string inside JSON, and a missing `exchangeResponse` means the host has not answered yet.
- **HostICECandidate**: Host ICE candidates lose their `a=` prefix, end-of-candidates and UDP lines with a `tcptype` are dropped, and a Teredo candidate (out-of-home console streaming) adds two IPv4 candidates on port 9002 and the mapped port before the original line.
- **TeredoAddress**: A Teredo address is 2001:0000:server:server:flags:port:client:client; the mapped port is XOR 0xFFFF and the client's public IPv4 address is bit-inverted.

## The stream

In StreamKit.

- **Package.swift**: webrtc-xcframework is pinned by revision because its tag 150.7871.02 is not valid semver (leading zero).
- **StreamRuntime**: one per app (created by AppDependencies, shared by every LiveStreamService); it creates the WebRTC factory lazily on the first peer, so field trials and SSL set-up still run only when the first stream starts.
- **StreamRuntime**: on iOS-family platforms the NWPathMonitor field trial must be set before any other WebRTC call, because a factory built with its own audio device skips the network filter the built-in modules install.
- **StreamRuntime**: LKRTCInitializeSSL must run once per process before any connection exists, or DTLS fails.
- **StreamRuntime**: the Mac uses MacStereoAudioDevice instead of WebRTC's legacy CoreAudio module, whose bursty pulls and ring buffer inflate the audio jitter buffer.
- **PeerConnection**: WebRTC holds its delegates weakly, so PeerConnection keeps a strong reference to DelegateProxy; without it every ICE, connection and data-channel event is dropped and a stream sits at Connecting forever.
- **PeerConnection**: link-local networks are disabled because ICE checks over Apple's peer-to-peer interfaces (awdl0, llw0) wake AWDL, which takes the radio off the network's channel for tens of milliseconds.
- **PeerConnection**: fast audio jitter-buffer accelerate is on because game audio is rarely quiet enough for NetEq's time-stretching; after a hiccup the buffer stayed about 80 ms above target (measured on the Mac: 200 vs 120 ms).
- **PeerConnection**: Swift imports setCodecPreferences:error: as throwing with a placeholder `error: ()` label to keep it distinct from the deprecated overload.
- **StreamController**: the selected candidate pair is the one the transport stats name, because both an IPv4 and an IPv6 pair can be nominated.
- **StreamController**: the reset-then-announce pair for slot 0 runs in a task so its 500 ms gap does not hold up other channel messages; the input sender starts only after the pair, so it cannot announce slot 0 in between.
- **InputSender**: input goes out on its own thread rather than a Task.sleep loop on the actor, so a press never waits for an actor hop and Swift's timers cannot coalesce the 8 ms wake-up.
- **InputState**: a Guide pulse rides on its slot even when no controller is connected.
- **GamepadRouter**: deliveries happen under the lock in the order states changed (controller queue and main-thread keyboard both write), so an older state never overtakes a newer one; destinations only record and wake the input thread and never call back in.
- **GamepadRouter**: slot 0 always gets a state when a destination is set because the host is told about slot 0 at connect time; every stream starts with no keyboard keys held, so a key still down when the last stream ended is not replayed.
- **GamepadRouter**: clearing pending input on TV delivers nil even for slot 0, whose normal path would merge the keyboard, so the sender drops latched taps before neutral states follow.
- **ControllerHub**: GCController.shouldMonitorBackgroundEvents stays on so input keeps arriving when the stream window is not key (a notification popped up).
- **ControllerHub**: connect and disconnect notifications only trigger a diff against GCController.controllers(), which keeps non-Sendable controller objects out of the main-actor closures.
- **ControllerHub**: a new controller's first state goes through the handler queue so it stays in order with the controller's own callbacks and a later disconnect.
- **ControllerInputDestination**: with direct routing the Home, Menu and Options buttons have their system gesture disabled so the Xbox / PS button reaches the game instead of opening the system's Games overlay; on TV, TVControllerInput toggles this with gameplay.
- **RumblePlayer**: it uses the standard pattern player on purpose: on macOS 27 an advanced player sends events gamecontrollerd rejects ("unexpected class AVHapticEvent"), which drops the engine connection and silences every later rumble; a stopped engine (idle controller, app lost focus) is restarted and the start retried once.
- **TVControllerInput**: all TV filtering runs on the controller queue; main-actor commands join that queue instead of adding a hop to each game input.
- **TVControllerInput**: UIKit may consume button releases while it has focus, so the held-control barrier is refreshed from the gamepads before gameplay resumes.
- **TVGamepadPolicy**: every button, Menu included, passes through to the game while playing; leaving gameplay sends neutral for every player and quarantines held controls until their physical release.
- **TVGamepadPolicy**: a removed controller is reported only as a removal; sending a neutral pad first would re-add the slot in the sender.
- **KeyboardGamepad**: key codes are hardware positions (NSEvent.keyCode, Carbon kVK_*), so WASD stays under the left hand on every keyboard layout.
- **StreamRenderer**: every frame is rendered in order, because dropping frames of a network burst would undo the pacing; only a backlog over 6 frames (a 60 fps burst after a Wi-Fi stall is a handful) drops the oldest.
- **StreamRenderer**: at most 12 output buffers are alive (the layer holds up to the Standard buffer, about 8 frames at 60 fps, plus the one being drawn); past that a frame is dropped rather than growing memory, since a full-screen 5K buffer is about 59 MB.
- **StreamRenderer**: enhanced frames are paced from the moment they are ready, so render time is part of the transit the pacer measures and its jitter is buffered too.
- **StreamRenderer**: clear() empties the system video layer on the render queue, after any frame being drawn, so that frame cannot reappear.
- **StreamRenderer**: the CoreVideo textures behind a frame's Metal textures must outlive the GPU work, hence the extended lifetime until the command buffer completes.
- **StreamRenderer**: the shaders keep the stream's primaries and transfer function, so output is tagged with the source's (BT.709 by default); tone-mapped output is half-float BT.2020 PQ, because 8-bit BGRA would band.
- **StreamRenderer**: the kept last frame holds one decoder buffer; the platform decides whether to keep it (Apple TV does not show console last frames).
- **SystemVideoPresenter**: the layer's sample-buffer renderer is taken once on the main actor; frames are queued on it from a background thread, which it supports, without touching the layer there.
- **SystemVideoPresenter**: changing the pacing mode mid-stream adjusts the existing pacer, because a fresh pacer would lose the last presentation time and schedule new frames before ones already queued.
- **FramePacer**: a frame is shown at capture time + transit floor + delay; the floor is the lowest transit per second over 10 s (follows clock drift and route changes), the delay covers the rank-th worst lateness of the recent window plus margin, rises at once and decays slowly, and a frame past its slot is shown at once.
- **VideoColorConversion**: the matrix and offset match the shader's ColorConversion layout (column-major 3x3, 16-byte-aligned offset); 10-bit bi-planar samples sit in the top bits of 16-bit words; untagged frames are treated as BT.709, which is what Xbox streams use.
- **StreamShaders.metal**: one full-screen triangle with y flipped for Metal's top-left origin; tone mapping keeps SDR white at 203 nits (BT.2408) and lifts the brightest parts towards 600 nits before BT.709 to BT.2020 and PQ encoding; sharpening is an independent take on contrast-adaptive sharpening that sharpens less where local contrast is already high.
- **AdaptiveQuality**: the Xbox lowers resolution on its own mid-stream when bandwidth runs short (measured: a 1080p stream capped at 3 Mbps went to 1280x720 at 60 fps after 9 s), so Automatic asks for 1080p and only explains what the host did.
- **AdaptiveQuality**: asking for cloud 1440p without Game Pass starts the session and ends it at once (measured with Fortnite), so such streams are pinned to 1080p.
- **StatisticsReport**: labels are fixed English on purpose, since the report is read by whoever receives it and compared across runs.
- **ControlMessage**: JSON keys are sorted only to keep output deterministic for tests; the host ignores key order.
- **PictureGeometry**: upscaling renders at the pixel size the picture occupies on screen (never below the stream's); without upscaling the stream's own size is used, since the layer scales anyway.
- **StreamViewModel**: it watches `Preferences` with `withObservationTracking` and applies picture, buffer and sound changes to the running stream, so a change made in Settings, the menu bar or the stream's own controls takes effect the same way; the watch ends with the stream.
- **StreamViewModel**: the sharpening menu offers four levels and shows the one nearest the saved strength, because Settings saves any strength on a slider.
- **StreamFailureAdvice**: a host message the app does not recognize is shown as it is, through the key `stream.advice.unrecognized %@`, so every advice is a `LocalizedStringResource`.
- **StreamOverlays**: each platform lists the statistics rows it shows (the Mac all of them, Vision Pro the ones a player acts on, Apple TV a short unlabeled list readable from the sofa) and how long the controls stay after the pointer stops (3 s on the Mac; never hidden elsewhere).
- **StreamPlatform**: each platform states what it applies: Vision Pro shows no picture modes (the window takes the picture's shape), Apple TV applies no enhancements and keeps no last frame, and only the Mac tone-maps to HDR, when a connected screen can exceed SDR white.

## Shared app

In StarfoldShared.

- **HomeViewModel, LibraryViewModel**: `onPlay`, `onRefreshAccount` and `onSignInRequired` are closures `AppViewModel` sets after creating the ViewModel instead of initializer parameters, which keeps each initializer to the four values that make it testable alone; a ViewModel nobody wired plays and refreshes nothing.
- **CloudAccessPresentation**: The cloud card has no subtitle while access is unknown, because its status already says Loading; the card keeps the empty line so it does not change height when the count arrives.
- **AppViewModel**: Pressing Play on the stream that is already starting or playing does nothing, because starting it again would cancel it and trip the host's duplicate-session check (HTTP 409).
- **AppViewModel**: The last frame of a console stream is taken before stop(), because stopping clears the renderer; only console streams that showed a picture keep one.
- **AppViewModel**: streamHome is weak so that a last frame taken after switching accounts or signing out mid-stream is dropped instead of landing in another account's cache.
- **AppViewModel**: endStream() clears `stream` only if it is still the one that was stopping, because a new stream may have started meanwhile.
- **AppViewModel**: qualityOverride pins a cloud stream of an account without Game Pass Ultimate to 1080p, since such accounts cannot get 1440p.
- **AppViewModel**: activate() shows the home screen at once and loads the profile, consoles and cloud library in the background, so the screen appears with placeholders instead of after every request.
- **AppViewModel**: The console list refresh loop is owned by AppViewModel and follows the app-wide scene phase, because a loop owned by a view stopped after an alert.
- **LiveConsoleService**: The gssv console list only includes consoles with remote play on; when it is empty the SmartGlass list is shown so the player learns why a console is missing.
- **HomeViewModel**: Presence does not say which console runs a game; only a console that is on can be running it, so the game is credited to the first console that is on.
- **ConsoleCover**: A console card prefers its own last frame over "playing now", because Xbox keeps reporting the game for a while after the stream ends.
- **LiveCloudLibraryService**: Cloud access is derived from the playable titles, not only from the offering, because the Game Pass offering also answers for lapsed or lower-tier accounts.
- **HomeViewModel**: A power command is done once the console accepts it; the console lists show the new state only about a minute later, so the app does not poll for it.
- **LiveCloudLibraryService**: Catalog names and art are optional; a failed lookup keeps the games playable without them.
- **LibraryCache**: The saved library is only a cache that makes the home screen instant; losing it costs one refresh. Last frames stay on the device because they can show private messages.
- **SignInViewModel**: An expired device code is replaced by a new one instead of an error, because the welcome screen can stay open for a long time.
- **SignInViewModel**: `shouldClose` turns true 0.9 seconds after signing in, so the Add Account sheet shows the success state before it closes; the welcome screen ignores it, because the app has already moved on to Home.
- **SignInViewModel**: It reaches the app through `SigningIn`, the two calls a sign-in needs, so a sign-in screen can neither read nor change anything else in `AppViewModel`.
- **SignInCode**: The address is shown as "microsoft.com/link" rather than "https://www.microsoft.com/link" because it is easier to read and type.
- **WelcomeFeature**: The list is shared but its words are not: each platform sells the console and itself in its own way, so each app presents the feature in its own `WelcomeFeaturePresentation`; only cloud gaming reads the same everywhere (`WelcomeCopy`).
- **SettingsViewModel**: `session` is the one dependency that is not an initializer argument: Settings lives as long as `AppViewModel`, which is created with it, so `AppViewModel` hands itself over as `SessionControlling` once both exist. The reference is weak because `AppViewModel` owns Settings.
- **QualityChoice**: The quality options are keys even for "720p" and "1080p", so a presentation returns one type, `LocalizedStringResource`, for every case.
- **StreamViewModel**: The first rumble from the host is logged once per stream to tell "the game sent none" from "it did not play".
- **LiveStreamService**: setDirectStereo does nothing on the Mac: StreamKit's runtime has no spatial-audio bypass there, so the call is the one `#if !os(macOS)` in StarfoldShared's services, around an API that does not exist on that platform.
- **LiveAccountService**: keeps the XboxAccount of every account it restored or signed in, by xuid, because the account actor holds the cached tokens; reading the account again from the store would refresh them for every profile request.
- **Palette**: Nebula matches the app icon's #6652E8; Sunrise keeps the exact values the app used before palettes existed, including the black-at-85-percent label colour and its coral glow.
- **SkyBackground**: The sky freezes on one fixed frame (time 12) under Reduce Motion, and on the Mac while the window is inactive.
- **PrimaryButtonStyle**: The hover growth is dropped under Reduce Motion; the hover lightening stays.
- **AppPalette**: Apple TV uses untintedAppPalette()/untintedPalette(_:) because there the palette only colours the sky and focused controls keep system colours.

## Mac

In `StarfoldMac/`.

- **AppDelegate**: A running stream is ended in applicationShouldTerminate because window onDisappear tasks never run during termination, which would leave the host session reserved until gssv times it out; quitting waits for it at most two seconds.
- **MenuBarMenu**: The menu bar extra is a standard menu because the custom panel it replaced did not bring the windows it opened to the front, so its buttons looked dead.
- **MenuBarMenu**: Console items are always enabled because the reported power state lags by about a minute; starting a stream says clearly when the console is off.
- **StreamWindowOpener**: Starting a stream activates the app, because from the menu bar the app is not active and the stream window would open behind other apps.
- **ProfileBadge**: The gamerpic is loaded at its original size (about 50 KB) because the gamerpic service rejects size parameters with HTTP 400.
- **MainWindowView**: The title bar is transparent with no visible title, but the window keeps the app name for the Window menu and Mission Control.
- **MainWindowView**: Each pushed page brings its own SkyBackground because NavigationStack pages are opaque.
- **MainToolbar**: The account menu is shown only when signed in, because signed out the welcome screen is the sign-in and a second sign-in would request a second code.
- **MainToolbar**: The flexible ToolbarSpacer keeps the clock and settings on the trailing edge once the title is removed.
- **HomeCard**: Every home card, skeleton and message card has the same height (`homeCardHeight`) so loading, empty and real cards line up without jumping.
- **ConsoleCard**: A console card shows only the status dot, without words, because the reported power state lags by about a minute and is a hint, not a promise; the words stay for VoiceOver.
- **ConsoleCard**: The wake button is disabled for a console that is off, because Off means Energy-saving mode, which ignores the wake command.
- **HomeCard**: The primary button carries words, not just a glyph, because a lone chevron did not say it opens the library; it is compact so it sits level with the round buttons beside it.
- **ConsoleCardArt**: A console card shows the game playing or last played on it rather than a picture of the box; Microsoft's artwork is loaded from its own servers like game covers.
- **WelcomeView**: Signed out, the sign-in itself sits beside the pitch, ready to scan the moment the window opens; there is no Sign In button to find first.
- **WelcomeView**: The sign-in task hangs off the GeometryReader, one real container for both layouts, so resizing between side by side and stacked never restarts it and replaces the code halfway through signing in.
- **SignInCodeStep**: Open Link also copies the code, because the link carries it but some pages still ask for it.
- **SignInHostView**: The host creates the screen's `SignInViewModel` in `onAppear`, not in `task`, so the sheet opens at its final size; until then it holds a clear view, because an empty view never appears.
- **GamepadButton**: A, B, X, Y, LB and RB are catalog keys with the same text in every language, so the name of every button is one `LocalizedStringResource`.
- **GameHero**: The hero art stretches on overscroll, moves with a gentle parallax on scroll, and fades itself out through a mask so it melts into the animated sky without a seam.
- **SettingsView**: Settings stay neutral in every palette because macOS draws the selected toolbar tab from the asset accent, which cannot follow a palette, so the controls do not either.
- **StreamView**: Only the black background runs under the title bar; the picture and overlays stay below it so the top of the game's HUD and the statistics are never hidden.
- **StreamView**: Every held key is released when the window stops being key, because keys released while another window has focus never reach the stream window.
- **StreamView**: isFullScreen lives here rather than in the control bar, which is rebuilt every time it reappears.
- **StreamStatusView**: The artwork is a background, not a stack sibling, because its fill size would set the stack's size and push the centred text and buttons off-centre; the blur is opaque so there is no grey halo where it samples past the window edge.
- **StreamStatusView**: The waiting page shows only a spinning ring and one short line; the only detail is the cloud queue estimate, where a wait of minutes would otherwise look stuck.
- **FullScreenObserverView**: Enter and exit full-screen notifications cover the control bar, Control-Command-F and the green title-bar button alike; the first report is deferred because viewDidMoveToWindow runs during SwiftUI's own update pass.
- **StatisticsReadout**: Latency is low under 50 ms (feels instant, green), moderate under 90 ms (noticeable in fast games, amber) and high above (sluggish, red); the stream's own size stays on its own row above the upscaled size, because what is shown as 4K is upscaled.
- **StreamStatisticsView**: The panel is fixedSize because the latency divider would otherwise stretch it across the window.
- **StreamVideoHostView**: A display link asks for 120 Hz while the stream is on a ProMotion or other high-refresh screen; frames still reach the system video layer on their own schedule, but the window server composites at 120 Hz, so a 60 fps frame waits 4.2 ms for a refresh on average instead of 8.3 ms. On a 60 Hz screen it changes nothing.
- **StreamKeyboardMonitor**: Keys are read with a local event monitor rather than a first responder, so they still reach the stream while SwiftUI controls in the overlay have focus; Command shortcuts pass through to the menu bar, and only the key event's Sendable parts cross into the main-actor closure.
- **StreamPictureInPicture**: The stream view creates one per stream and hooks StreamViewModel.onStop (dismiss without bringing the window back) and onEnd (return to the window, where the end page explains what happened).
- **StreamPictureInPicture**: Picture in Picture is a floating panel that takes the stream's own video layer, not AVPictureInPictureController, because on macOS 27 the system floating window showed a sample-buffer layer at the source window's size and position instead of scaling it, so the picture came out cropped (reproduced in a minimal app).
- **StreamPictureInPicture**: While the picture floats, controllers are monitored in the background, because the player is likely in another app and otherwise the controller only reaches the frontmost app. isPossible stays for the callers' enabled state; a floating panel can always be opened.
- **StreamPictureInPicture**: dismiss() takes the floating panel away without touching the stream window, for a stream stopped from elsewhere (another one is starting); stop() returns to the window when the stream ends so its end page can speak.
- **PictureInPictureView**: MetalFX upscales to the floating panel's pixels, not the hidden stream window's; a double-click returns to the window like the system's own Picture in Picture.

## Apple Vision Pro

In `StarfoldVision/`.

- **RootView**: Settings stay reachable as a tab before signing in.
- **StreamView**: The stream controls are always shown while streaming, in an ornament below the window, because on Vision Pro a tap to summon them and a timer to hide them only got in the way; the controller goes straight to the game wherever the player looks.
- **StreamView**: The control ornament is anchored at the scene's bottom with top content alignment so its top edge sits on the window's bottom edge, because the default bottom toolbar ornament overlaps the window's lower edge and covered the picture.
- **StreamView**: The black fill sits only behind the picture (after the first frame); the waiting screen is glass with its own corners.
- **StreamStatusView**: The artwork is a background of the status view, not a child of its stack, because in the stack its fill size set the stack's size and pushed the centred text and buttons off-centre; the view fills the window so connecting is the same size as the picture that follows.
- **VideoHostView**: A GCEventInteraction handling gamepad events claims the controller for the game, because by default visionOS turns controller buttons into pinches aimed at whatever the player is looking at.
- **VideoHostView**: The window scene is restricted to uniform resizing so the picture keeps filling the window without black bars.
- **ConsoleCard**: The power state is shown only as a dot, without words, because the reported power state lags by about a minute.
- **ConsoleCard, GameHero, SignInCodeStep**: Play and Sign In use an HStack centred on the icon instead of a Label, because a Label's text baseline sat the words below the middle of the glyph and the button.
- **GameDetailView**: The game page uses the inline title display mode because the name is already large on the art; the bar only carries the back button.
- **SignInCodeStep**: Sign In copies the code to the pasteboard before opening the link that already carries it, for Microsoft pages that still ask for the code; there is no QR code because a phone can't scan a code shown inside the headset.
- **WelcomeView**: The welcome screen uses system glass and colours only; visionOS has no palette.

## Apple TV

In `StarfoldTV/`, TopShelfKit and `StarfoldTopShelf/`.

- **RootView**: Every Play on Apple TV goes through `StreamPresenter`, which asks for a controller first and owns the full-screen cover, so RootView sets `AppViewModel.onPlayRequest` to it; without that the app would start the stream with nothing showing it.
- **LibraryView, SearchResultsView**: The search text lives in `LibraryViewModel` and Search is a tab of its own, so the Cloud Gaming tab reads the lists the search text does not change (`shelves`, `games`) and shows its library when the placeholder is `noResults`; only the Search tab reads `searchResults`.
- **RootView**: A Top Shelf link that arrives while the account is still restoring is kept in pendingLink and followed once restoring ends.
- **LibraryHostView**: The library's navigation path is owned by RootView so a Top Shelf link can open a game's page.
- **SettingsHostView**: The settings root has no navigation title because the selected tab already names the page.
- **ConsoleCard**: A console card's artwork alone shows the last game; there is deliberately no caption over it, only the model name when there is no activity.
- **HomeCard**: The Mac card hierarchy becomes one system card button on Apple TV: the whole card takes focus and secondary actions (power) live in its context menu.
- **SignInCodeStep**: Device-code sign-in shows a QR code for the phone and the code for any other device; Apple TV has no browser, so there is nothing to press while waiting.
- **WelcomeView**: Signed out, the app explains itself on the left and shows the sign-in panel on the right, ready to scan the moment the app opens; signing in on the phone goes straight to Home.
- **StreamPresenter**: Ending waits for a cancelled start before clearing the stream, so an old token request can never open a session after returning to the library.
- **StreamPresenter**: end(presentationID:) ignores a full-screen dismissal from an earlier presentation, because it may arrive after a retry has already presented another stream.
- **StreamPresenter**: Any explicit end (user cancel, account switch, background) bumps restartRequest so a restart still waiting for cleanup is dropped.
- **StreamPresenter**: goBack() closes the control menu when it is open and ends the stream otherwise; the menu is a system sheet that normally handles its own Back.
- **StreamHost**: UIKit (a GCEventViewController) owns event routing for the whole full-screen stream subtree, including its SwiftUI controls.
- **StreamEventViewController**: Remote handlers leave system gestures enabled, so a long Back press and the TV button still go Home.
- **StreamEventViewController**: Back and Play/Pause act on button release, so restoring focus cannot consume the same Back press again and routing changes only after the press ends.
- **StreamEventViewController**: The Siri Remote's Play/Pause button is microGamepad.buttonX.
- **StreamMenuView**: The control menu is a system sheet fitted to its rows (look, focus and Back are the system's) and holds only commands for the running stream; next-stream settings live in Settings.
- **SystemDialogView**: Shows a message box or text prompt the game asked the client to show, as a sheet over the stream.
- **StreamPresenter**: Raw controller input reaches the game only while the picture shows with nothing over it (no dialog, menu, sign-in alert or ending notice), the app is in front and a controller is connected; otherwise focus stays with the system so the remote can answer.
- **PreviewObjectPool**: The preview system dialogs equal what MessageChannel parses from the host's ShowMessageDialog / ShowVirtualKeyboard transactions (see streaming.md).
- **ContentProvider**: Returning nil shows the static Top Shelf image; the provider runs on the extension's own queue and touches no UI, so it is nonisolated.
- **TopShelfSnapshot**: The app writes the snapshot into the shared App Group container; the extension holds no account token and fetches nothing (the system loads the image URLs), and section titles arrive already localized so the extension carries no strings.
- **TopShelfSnapshot**: init?(app:) is nil while restoring so a relaunch does not blank the Top Shelf; signing out gives an empty snapshot, which clears it.
- **TopShelfSnapshot**: Game items prefer wide art with the title logo, so a row of pictures still says which game each one is.
- **TopShelfSnapshot**: rowItemLimit is 10 because a row should at least span the screen and more is never visible without scrolling.
- **TopShelfStore**: save(_:) returns whether the stored snapshot changed, so callers only nudge the system when it did.
