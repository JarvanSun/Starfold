# Product

What a player can do in Starfold. A behaviour not here is not built; a feature changes this file
before its code.

Starfold streams Xbox games to Mac, Apple Vision Pro, Apple TV, iPhone and iPad: remote play from
the player's consoles, and Xbox Cloud Gaming. It talks to Microsoft's and Xbox's services
directly; there is no Starfold server. The welcome screen says Starfold isn't affiliated with or
endorsed by Microsoft.

## Accounts

- Signed out, the welcome screen shows the sign-in at once: a code in boxes, "or enter the code at
  microsoft.com/link" and, on Mac and Apple TV, a QR code. Open Link (Mac) or Sign In (Vision Pro,
  iPhone, iPad) copies the code and opens the link with it filled in.
- "Waiting for sign in…", then "Signing in…" after the browser step; then Home appears at once
  with placeholders. An expired code is replaced; a declined sign-in or an error shows the reason
  and Get a New Code.
- Launch restores the last used account; tokens refresh before they expire. A rejected stored
  sign-in shows "Sign-in expired" with Sign In or Not Now.
- The account menu (avatar, gamertag, gamerscore) has Switch Account, Add Account… (sign-in in a
  sheet that closes once signed in) and Sign Out…. Switching replaces profile, consoles, library
  and favourites.
- Sign Out asks "Sign out of <gamertag>?", deletes the account's sign-in, saved library and console
  snapshots from the device, and moves to the next saved account or the welcome screen.

## Home and consoles

- Home shows the account's last saved library at once; the refresh replaces it.
- A card per console and, on Mac and Apple TV, one for Xbox Cloud Gaming; recently played cloud
  games underneath.
- A console card shows name, model and a power-state dot, a hint only (the reported state lags
  about a minute). On Wi-Fi it adds a Wi-Fi symbol: "On Wi-Fi. A wired connection is steadier."
- Consoles with remote play on are listed; if there are none, the account's other consoles. None
  at all: "No consoles", "Turn on Remote features on your Xbox." and Refresh. A failed list:
  "Couldn't load consoles", the reason and Try Again.
- The list refreshes every 30 s while the app is active, and at once on return if older than 10 s.

| Console state | Power button | Effect |
|---|---|---|
| On | Turn Off | Sends the power-off command |
| Sleeping | Wake Up | Sends the wake command |
| Off (Energy-saving mode) | Disabled | Tooltip: remote wake needs Power mode set to Sleep; turn it on by hand, then press Play |

- A power command is done once the console accepts it; the app does not wait for the new state. A
  rejected or lost one shows "Couldn't reach <console>", "Check that Remote features are on, then
  try again."
- **Cover:** the last frame of the console's last stream that showed a picture, else the game
  playing on (or last seen on) that console, else the model name; never a cloud or PC game. Last
  frames stay on the device, per account; Apple TV keeps none.

## Cloud Gaming

- Only games the account can play (Game Pass or free to play), with names and art from the
  Microsoft Store catalogue; a part of the catalogue that fails loses only its names and art.
- Without Game Pass the library falls back to free-to-play games and says so. Without cloud gaming
  (account or region): "Cloud gaming isn't available", "Needs Xbox Game Pass in a supported
  region.", not as an error.
- The cloud card shows Available, Free to play, Unavailable or Loading…, the game count and Browse
  Games.
- **Rows**, each only with games: Continue Playing, Favorites, Recently Added, Leaving Soon (with a
  "Leaving" badge). Curated rows hold only playable games.
- **All Games** with its count, sorted by Name or Recently Played (played first, most recent
  first, the rest by name); the choice is remembered.
- **Search** matches name or publisher, ignoring case and surrounding spaces; while searching the
  rows hide and the grid becomes Results.
- **Game page:** art, title, publisher, input badges, Play, favourite heart, then About, genres,
  developer, release date, screenshots. Favourites are per account and survive relaunch.

## Streaming

- Play on a card, tile, game page or the menu bar opens the stream and starts the session; on a
  target already starting or playing it only brings that stream forward.
- Waiting shows the name, one progress indicator, "Connecting…" and Cancel; in the cloud queue, "In
  line — about N minutes" or "Waiting in line…". Behind it: the game's art blurred, or the sky.
- Every wait times out or ends with Cancel. Closing the stream ends the host session without
  confirmation.
- The end page says Stream ended, Session ended, Connection lost, Connection failed or (iPhone,
  iPad) Stream ended while you were away, with advice for a failure, and offers Close and Try
  Again.
- Game message boxes and text prompts appear as sheets and are answered there.
- The stream never pops up a network or quality notice.

### Settings that shape a stream

| Setting | Options | Default | Where |
|---|---|---|---|
| Console quality | Automatic, 720p, 1080p, 1080p High Bitrate | Automatic | All |
| Cloud quality | Automatic, 720p, 1080p, 1440p (Game Pass Ultimate) | Automatic | All |
| Cellular quality | Automatic, 720p, 1080p | 720p | iPhone, iPad with cellular |
| Maximum bitrate | Automatic, 10–80 Mbps | Automatic | Mac, Vision Pro, iPhone, iPad |
| MetalFX upscaling | On, Off | On | Mac |
| Sharpening | Off to High | Low | Mac |
| Picture Mode | Fit; Fill (crops the edges); Scale (stretches to the view's shape) | Fit | Mac, Apple TV, iPhone, iPad |
| HDR tone mapping | On, Off; shown only with an HDR screen connected | Off | Mac |
| Buffer | Standard (at most 120 ms), Low Latency (at most 40 ms) | Standard | All |
| Show statistics | On, Off | Off | All |
| Game language (cloud) | System or one of 12 languages | System | All |
| Keyboard as controller | On, Off | On | Mac, iPhone, iPad |
| Rumble | On, Off | On | All |
| Touch haptics | On, Off | On | iPhone |

- Automatic asks for 1080p; when bandwidth runs short the Xbox lowers the resolution mid-stream
  and keeps the frame rate. A fixed tier is a ceiling. Without Game Pass, cloud streams at 1080p,
  never 1440p.
- Cellular quality caps both qualities for the whole of a stream that starts on cellular data.
- Quality and bitrate are fixed per session: changing one mid-stream shows "Restart the stream to
  use the new quality." with Restart Stream (Mac). Every other setting applies at once; a Buffer
  switch keeps queued frames.
- The stream is at most 1080p from a console and 1440p from the cloud; upscaling renders it at the
  picture's size on screen. HDR tone mapping spreads it over the screen's HDR range and says it is
  not native HDR.
- Touch haptics: a tap on a touch control and, with no controller, host rumble play on the device.

### Statistics

- First line: estimated latency (round trip + jitter buffer + decode + display), with a green,
  amber or red dot on Mac, Vision Pro, iPhone and iPad. Then each line the stream has a value for:
  - **Mac:** resolution and codec (marked Automatic), upscaled size, SDR → HDR tone mapping,
    "Lowered from <tier>", frame rate, bitrate, network path (Local network, Internet or Relay;
    Wi-Fi or Ethernet), round trip, decode, jitter buffer, display, packet loss.
  - **Vision Pro:** resolution (marked Automatic), "Lowered from <tier>", frame rate, bitrate,
    round trip, decode, jitter buffer, packet loss.
  - **Apple TV:** resolution, frame rate, bitrate, codec, "Lowered from <tier>", unlabeled.
  - **iPhone, iPad:** resolution (marked Automatic), "Lowered from <tier>", frame rate, bitrate,
    network path (as on Mac, or Cellular), round trip, packet loss.
- Copy Statistics (Mac) copies the figures as English plain text, noting that controller input and
  the host's capture and encode are not included.

### Input

- Controllers feed the stream directly. A press between two samples is still sent; unplugging
  sends one neutral state. Host rumble plays unless Rumble is off. Settings list controllers with
  player slot, battery and Test Vibration (Mac, Vision Pro, iPhone, iPad).
- **Xbox button:** goes to the Xbox while Starfold is in front. From macOS, iOS and visionOS 27 the
  player's game controller settings can keep it for the system, which Starfold cannot override;
  then, with a controller connected, Settings and the connecting page say the system is handling
  the Xbox button, with a link to the system's controller settings.
  The stream's own Xbox Guide control always works. Apple TV gives the button to the Xbox only
  during play.
- **Keyboard as controller** (Mac; iPhone and iPad with a hardware keyboard) goes by key position:
  WASD left stick, IJKL right stick, arrows D-pad, Space A, Esc or Delete B, F X, R Y, Q LB, E RB,
  Z and C triggers, Return Menu, Tab View, Shift and V stick presses.
- Diagonals stay on the unit circle, opposite keys cancel, keyboard and controller on one player
  merge. Unbound keys and Command shortcuts pass through. Keys release when the window loses
  focus; every stream starts with none held.

### Errors and advice

A host error becomes the step that fixes it; only an unrecognised one is shown as is.

| Host says | Player reads |
|---|---|
| Console not registered | Your console is offline. Make sure it's on or asleep and signed in. |
| Streaming disabled | Remote play is off. Turn on Remote features on your Xbox. |
| Start not found right after a stream | Your console is still closing the last stream. Try again in a few seconds. |
| Timed out waiting for the console | Your console didn't answer. Make sure it's on or asleep, not in Energy-saving mode, then try again. |
| Duplicate session | This game is still starting from your last try. Wait a moment, then try again. |
| HTTP 400 when starting | This game needs Xbox Game Pass. |
| Sign-in no longer valid | Your sign-in expired. Sign in again to keep playing. |
| Connection lost mid-stream | Check your network, then try again. |

## Mac

- **Main window:** one window, 1180 × 760 by default, reopened as the same window: the cards and
  Continue Playing (up to 10). Toolbar: account menu leading, clock and Settings trailing, no
  visible title. Library and game pages push inside it, with search in the toolbar.
- **Stream window:** separate, 1280 × 720 by default and at least 640 × 360, full screen on its
  own, never restored at launch; only the picture and overlays. Quitting mid-stream ends the host
  session first, waiting at most 2 s.
- **Control bar:** icon-only Xbox Guide, Statistics, Picture (MetalFX Upscaling, HDR Tone Mapping,
  Picture Mode, Sharpening, Buffer), Picture in Picture, Full Screen and Disconnect. It shows when
  the pointer moves or the picture starts, and hides with the pointer after 3 s still.
- **Menu commands:** every control-bar command but Sharpening, plus:

| Command | Shortcut |
|---|---|
| Open Xbox Guide | ⌘G |
| Show Statistics / Copy Statistics | ⌘I / ⌥⌘C |
| MetalFX Upscaling, HDR Tone Mapping (with an HDR screen) | — |
| Picture Mode: Fit, Fill, Scale | ⌃⌘1–3 |
| Buffer: Standard, Low Latency | ⌥⌘1–2 |
| Use Keyboard as Controller | ⇧⌘K |
| Picture in Picture / Request Fresh Picture | ⌥⌘P / ⌥⌘R |
| Disconnect (closes the stream window) / Full Screen (View menu) | ⌘W / ⌃⌘F |
| Refresh Library (View menu) | ⌘R |

- **Picture in Picture:** the stream window hides and the picture continues in a floating 16:9
  window on every Space. Back to Window or a double-click returns; Disconnect ends the stream; a
  stream the host ends returns to the window. Controllers keep working with another app in front.
- **Menu bar extra:** gamertag (or a sign-in hint), Consoles (each starts a stream; "<console> ·
  Playing <game>" when known), three Continue Playing games, controllers with battery, Open
  Starfold, Settings… (⌘,), Quit (⌘Q). Windows it opens come to the front. Settings can hide it.
- **Settings window:** Streaming (restart note, Quality, Cloud Gaming, Appearance: palette and menu
  bar icon), Picture (upscaling, sharpening, HDR, Picture Mode, statistics, Buffer), Controls
  (controllers, the Xbox button note, Rumble, keyboard toggle and key table). Each home card's gear
  opens it.

## Vision Pro

- **Tabs** (system vertical tab bar): Sign In and Settings signed out; Home, Cloud Gaming and
  Settings signed in. The account menu is in Home's toolbar.
- **Home:** console cards (Play, power button, Wi-Fi hint), then Continue Playing (up to 8); no
  cloud card. Cloud Gaming has search and a sort menu in the toolbar.
- **Stream window** replaces the main window (1280 × 720, 16:9), connecting page included; closing
  it ends the stream and brings the main window back.
- **Controls:** an ornament below the window, never over the picture, always shown while
  streaming: Xbox Guide, Statistics, Stream Options (Buffer and Sound), Disconnect. No Picture
  Mode, upscaling or sharpening.
- **Sound stage:** Follow Window (default) plays from the stream window, Direct Stereo straight to
  both ears; switching is immediate. Sound is stereo, mixes with other apps, returns after
  interruptions and is released when the stream ends.
- **Settings tab:** Quality, Cloud Gaming, Picture (Buffer, statistics), Sound, Controllers. No
  palette.
- During a stream Wi-Fi stays on the router's channel (low-latency streaming).

## Apple TV

- **Tabs** at the top: Home, Cloud Gaming, Settings, the system search tab. Browsing and sign-in
  need only the remote.
- **Home:** focusable console and cloud cards, then a Recently Played shelf. Selecting a console
  starts it; a long press offers Wake Up or Turn Off.
- **Cloud Gaming:** Continue Playing, Favorites, Recently Added, Leaving Soon and All Games by
  name; search only in its tab.
- **Controller required:** a stream starts only with an extended game controller connected;
  otherwise "Connect a Controller" explains pairing, with Check Again, then Play. The remote never
  takes a player slot.
- **Stream:** full screen. Play/Pause opens a system sheet (Xbox Guide, Statistics, Picture Mode,
  Disconnect) that Back closes and no timer hides; Back during play ends the stream. The
  controller's Menu button always goes to the Xbox.
- Menus, game dialogs and leaving the app send the Xbox a neutral controller; a control held
  through them counts only after release. Going to the background ends the stream and session.
- **Settings:** Quality (no bitrate), Cloud Gaming, Picture (Buffer, statistics), Controllers,
  Account (switch, Add Account, Sign Out…), Appearance (palette). No upscaling, sharpening or HDR.
- **Top Shelf:** Continue Playing and Consoles rows, up to 10 items each, from what the app last
  saved; the Top Shelf never signs in or fetches. A game opens its page and Play starts it; a
  console starts a stream from Home. Signing out clears the rows; with nothing to show, a static
  image without text appears.

## iPhone and iPad

One app for both. Layout follows the size class of the space the app has, never the device, so
iPad Split View, Stage Manager and an unfolded iPhone Duo each get the layout that fits.

- **Tabs** when signed in: Home and Settings, at the bottom on iPhone and the top on iPad; no
  sidebar. The account menu is in Home's toolbar.
- **Signed out:** the welcome page, no tabs, Settings in a sheet behind a gear. On iPhone the app
  icon and three steps (sign in, pick a console or a cloud game, play) sit above a sign-in sheet
  fixed to the bottom; in landscape they blur behind a centred sign-in card. A wide iPad window
  puts them beside the card; a narrower one stacks icon, steps and card in one centred column.
- **Home:** console cards, the Xbox Cloud Gaming row (three covers, availability, game count),
  then Continue Playing (up to 10). On iPhone one card fills the width and the cards page sideways;
  in landscape a card lies on its side, art left, details right. On iPad Mac-sized cards sit in a
  row. With no cloud access the row says why and does not open.
- **Controller and keyboard:** Home starts on the first console card; select (A, Return or Space)
  plays, holding it or touching and holding offers Wake Up or Turn Off. The Cloud Gaming row opens
  the library; a Continue Playing game plays.
- **Cloud Gaming** opens from that row: the Mac's rows and All Games, a sort menu (Name, Recently
  Played) and a search field under the title; no search tab. With a controller, focus starts on
  the first game, not the search field; selecting a game opens its page, holding it offers Play.
- **Game page:** as on Mac, plus a Touch badge when the title has a touch layout. Focus starts on
  Play.
- **Settings:** Streaming (console, cloud and Cellular quality, Maximum Bitrate, Buffer, Game
  language), Display (Picture Mode, statistics, Color), Controls (Edit Layout and Touch haptics
  when touch controls exist, the controllers, the Xbox button note, Rumble, Keyboard as
  controller), Account (switch, Add Account, Sign Out…). Only a state the player must act on adds
  a line; a choice names the option alone, never a recommendation. Cellular quality shows only on
  a device with cellular data. On a wide iPad the rows keep a readable width.
- **Stream:** full screen, status bar and Home indicator hidden, system edge gestures deferred.
  iPhone streams in landscape only; iPad in any orientation and window size. The waiting and end
  pages are the Mac's.
- **Stream menu:** a handle at the top centre opens it; the handle dims after 3 s and hides while
  a controller is in use, until a tap. Xbox Guide, Statistics, Disconnect, then Picture Mode,
  Buffer and Edit Touch Controls; tapping outside closes it.
- **Interruptions:** Control Center, a notification, the app switcher or a call keeps the stream
  going and sends the Xbox a neutral controller; a control held through it counts only after
  release.
- **Background:** going to the Home Screen, another app or Notification Center mutes the sound and
  keeps the stream for as long as iOS allows, at most a minute. Coming back in time carries on with
  a fresh picture; otherwise the session ends just before the time runs out, and coming back shows
  Stream ended while you were away with Close and Try Again.
- No Picture in Picture. **Sound** plays with the Ring/Silent switch on silent, pauses for calls
  and is released when the stream ends.
- **Haptics**, following the system's haptics setting, mark outcomes (a stream starting, ending or
  failing, sign-in, a power command) and direct manipulation (selecting, dropping or resetting in
  Edit Layout, a sort or stick choice, a favourite, the stream menu, a controller connecting).

### Touch controls

Starfold follows Xbox Cloud Gaming's own behaviour rather than inventing one.

- **When:** only with no controller connected; no setting. Controller input (a keyboard counts)
  hides them; touching the screen or disconnecting the last controller brings them back.
- **Layout:** a title with its own touch layout (Xbox Touch Adaptation Kit) gets it, in cloud and
  remote play, and the game decides when it shows, hides or changes. Every other title gets the
  standard Xbox layout: left stick, D-pad, LB, LT and left stick click on the left; A, B, X, Y, RB,
  RT, right stick and its click on the right; View and Menu at the top right.
- A title layout falls back to the standard one, rather than leave a control out, when Touch
  Controller cannot draw it as the game meant: throttles, touchpads, arcade groups, layer
  switches, turbo, toggle or pull buttons, several controls in a slot, centre controls, mouse
  output. A title that reads touch directly gets the standard layout until Pointer reports are
  specified in [streaming.md](streaming.md).
- **Look and feel:** Apple Touch Controller's system controls over the picture. A press highlights
  at once and, with Touch haptics on, taps. On the standard layout each half of the screen is its
  stick's area, so a stick starts where the thumb lands. Buttons carry Xbox names, since Starfold
  cannot know what each does in a game.
- **Edit Layout** (Settings and the stream menu) changes the standard layout only, per device and
  orientation: drag to move, select to resize, set the opacity; Reset restores the default. A
  close button sits top left; a pill at the top centre holds the hint (or the selected control's
  name), Opacity and Reset; a selected control gets a small inspector beside it, towards the
  middle of the screen. Both fade while a control is dragged.
- **Sticks** show Always, On Touch (drawn under the thumb only while it is down) or Off (its half
  of the screen does nothing). Other controls keep their places, so turning a stick back on
  restores the layout. In the editor an On Touch or Off stick is a dashed outline, and Size is
  unavailable while it is Off. The choice covers both orientations, Reset restores Always, and a
  title's own layout always shows its sticks.
- **Rumble** plays on the controller or, with only touch controls and Touch haptics on, as iPhone
  haptics.

### iPhone Duo

Built after iPhone and iPad are finished.

- Closed (outer display): the iPhone layout. Fully open: the layout the inner display's size class
  gives. Moving between displays or folding keeps the stream, its menu state and the player's
  place, without reconnecting.
- **Half folded:** the picture sits above the fold and the touch controls fill the half below;
  nothing overlaps the picture. With a controller in use the lower half is empty but for the
  stream menu handle and, when on, statistics. The fold position comes from the system's reserved
  regions, never the hinge angle.

## Out of scope

Other streaming services, mouse and keyboard passthrough (a keyboard only plays as a controller),
voice chat, notifications, analytics, light palettes, curved or immersive screens on Vision Pro, a
server of our own. Adding one changes this list first.
