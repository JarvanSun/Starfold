# Product

What a player can do in Starfold. A behaviour not here is not built; a feature changes this file
before its code.

Starfold streams Xbox games to Mac, Apple Vision Pro, Apple TV, iPhone and iPad: remote play from
the player's consoles, and Xbox Cloud Gaming. It talks to Microsoft's and Xbox's services directly; there is no
Starfold server. Text names the app only by `AppInfo().displayName`, in English and Simplified
Chinese; the welcome screen says Starfold isn't affiliated with or endorsed by Microsoft.

## Accounts

- **Device code.** Signed out, the welcome screen shows the sign-in at once: the code in boxes,
  "or enter the code at microsoft.com/link", and a QR code on Mac and Apple TV (not Vision Pro,
  iPhone or iPad, where the link opens on the same device). Open Link (Mac) or Sign In (Vision Pro,
  iPhone, iPad) copies the code and opens the link with it filled in.
- "Waiting for sign in…" while polling, "Signing in…" after the browser step; then Home appears at
  once with placeholders. An expired code is replaced; a declined sign-in or an error shows the
  reason and Get a New Code.
- Launch restores the last used account. Tokens refresh before they expire, once for any number of
  concurrent requests. A rejected stored sign-in shows "Sign-in expired" with Sign In or Not Now.
- **Multiple accounts.** The account menu (avatar, gamertag, gamerscore) has Switch Account,
  Add Account… (the sign-in panel in a sheet that closes once signed in) and Sign Out…. Switching
  replaces profile, consoles, library and favourites.
- Sign Out asks "Sign out of <gamertag>?", then moves to the next saved account or the welcome
  screen. The account's keychain entry, library cache and console snapshots are deleted.

## Home and consoles

- Home shows the account's last saved library at once; the refresh replaces it.
- One card per console and, on Mac and Apple TV, one for Xbox Cloud Gaming, with recently played
  cloud games underneath. Loading shows placeholder cards; an empty or failed state is one line and
  one action.
- Consoles with remote play on are listed by name with model and a power-state dot. The dot is a
  hint (the reported state lags about a minute); its words go to VoiceOver. A console on Wi-Fi
  shows a Wi-Fi symbol: "On Wi-Fi. A wired connection is steadier."
- If no console has remote play on, the account's other consoles are listed anyway. None at all:
  "No consoles", "Turn on Remote features on your Xbox." and Refresh. A failed list: "Couldn't load
  consoles", the reason and Try Again.
- While the app is active the list refreshes every 30 s; returning refreshes it at once if older
  than 10 s.

| Console state | Power button | Effect |
|---|---|---|
| On | Turn Off | Sends the power-off command |
| Sleeping | Wake Up | Sends the wake command |
| Off (Energy-saving mode) | Disabled | Tooltip: remote wake needs Power mode set to Sleep; turn it on by hand, then press Play |

- A power command is done once the console accepts it; the app does not wait for the new state. A
  rejected or lost command shows "Couldn't reach <console>" with "Check that Remote features are
  on, then try again."
- **Snapshots.** When a console stream that showed a picture ends, its last frame becomes the
  card's cover. Cover order: last frame, else the game playing on (or last seen on) that console,
  else the model name; a cloud or PC game never appears on a console card. Snapshots are JPEGs on
  the device, per account, deleted on sign-out. Apple TV keeps none.

## Cloud Gaming

- Only games the account can play (Game Pass or free to play), with names and art from the
  Microsoft Store catalogue, fetched in parallel batches; a failed batch loses only names and art.
- Without Game Pass the library falls back to free-to-play games and says so. Without cloud gaming
  (account or region): "Cloud gaming isn't available", "Needs Xbox Game Pass in a supported
  region.", not an error. The cloud card shows Available, Free to play, Unavailable or Loading…,
  the game count and Browse Games.
- **Rows**, each shown only with games: Continue Playing, Favorites, Recently Added, Leaving Soon
  (with a "Leaving" badge). Curated rows contain only playable games.
- **All Games** with its count, sorted by Name or Recently Played (played first, most recent
  first, the rest by name); the choice is remembered.
- **Search** matches name or publisher, ignoring case and surrounding spaces. While searching the
  rows hide and the grid becomes Results; no match shows the system's no-results view.
- **Game page:** art, title, publisher, input badges, Play, favourite heart, then About, genres,
  developer, release date, screenshots. Favourites are per account and survive relaunch.

## Streaming

- Play on a card, tile, game page or the menu bar opens the stream window and starts the session.
  Playing a target already starting or playing only brings its window forward.
- Waiting shows the name, one progress indicator, "Connecting…" and Cancel; in the cloud queue
  "In line — about N minutes" or "Waiting in line…". Behind it: the game's art blurred, or the sky.
- Every wait times out or ends with Cancel. Closing the stream window ends the host session without
  confirmation. The end page says Stream ended, Session ended, Connection lost or Connection
  failed, with advice for a failure, and offers Close and Try Again.
- Message boxes and text prompts from the game appear as sheets and are answered there.

### Settings that shape a stream

| Setting | Options | Default | Where |
|---|---|---|---|
| Console quality | Automatic, 720p, 1080p, 1080p High Bitrate | Automatic | All |
| Cloud quality | Automatic, 720p, 1080p, 1440p (Game Pass Ultimate) | Automatic | All |
| Cellular quality | Automatic, 720p, 1080p; a ceiling over the console and cloud quality for a stream that starts on cellular data | 720p | iPhone, iPad with cellular |
| Maximum bitrate | Automatic, 10–80 Mbps | Automatic | Mac, Vision Pro, iPhone, iPad |
| MetalFX upscaling | On, Off | On | Mac |
| Sharpening | Off to High | Low | Mac |
| Picture Mode | Fit; Fill (crops the edges); Scale (stretches to the view's shape) | Fit | Mac, Apple TV, iPhone, iPad |
| HDR tone mapping | On, Off; shown only with an HDR screen connected | Off | Mac |
| Buffer | Standard, Low Latency | Standard | All |
| Show statistics | On, Off | Off | All |
| Game language (cloud) | System or one of 12 languages | System | All |
| Keyboard as controller, Rumble | On, Off | On | Keyboard: Mac, iPhone, iPad; Rumble: all |
| Touch haptics | On, Off: a tap on a touch control and, with no controller, host rumble play on the device | On | iPhone |

- Automatic asks for 1080p; when bandwidth runs short the Xbox lowers resolution mid-stream and
  keeps the frame rate. Fixed tiers are ceilings. A free-to-play account (no Game Pass) never asks
  for cloud 1440p and streams at 1080p.
- Quality and bitrate are fixed per session: changing one mid-stream shows "Restart the stream to
  use the new quality." with Restart Stream (Mac). Every other setting applies at once.
- Upscaling renders to the picture's pixel size on screen; the stream itself is at most 1080p from
  a console and 1440p from the cloud.
- HDR tone mapping spreads the SDR stream over the screen's HDR range (reference white 203 nits,
  highlights about 600 nits); it says it is not native HDR.
- Frames are shown by the host's capture time. Standard buffers what recent hiccups need, at most
  120 ms; Low Latency at most 40 ms. Switching mid-stream keeps queued frames. On a high-refresh
  Mac screen the display runs at 120 Hz.

### Statistics

- Top-leading overlay. First line: estimated latency (round trip + jitter buffer + decode +
  display), on Mac, Vision Pro, iPhone and iPad with a green (< 50 ms), amber (< 90 ms) or red
  dot.
- Then each line the stream has a value for:
  - **Mac:** resolution and codec (marked Automatic), upscaled size, SDR → HDR tone mapping,
    "Lowered from <tier>", frame rate, bitrate, network path (Local network, Internet or Relay;
    Wi-Fi or Ethernet), round trip, decode, jitter buffer, display, packet loss.
  - **Vision Pro:** resolution (marked Automatic), "Lowered from <tier>", frame rate, bitrate,
    round trip, decode, jitter buffer, packet loss.
  - **Apple TV:** resolution, frame rate, bitrate, codec, "Lowered from <tier>", unlabeled.
  - **iPhone, iPad:** resolution (marked Automatic), "Lowered from <tier>", frame rate, bitrate,
    network path (Local network, Internet or Relay; Wi-Fi, Ethernet or Cellular), round trip,
    packet loss.
- The stream never pops up a network or quality notice.
- Copy Statistics (Mac) copies the figures as English plain text, noting that controller input and
  the host's capture and encode are not included.

### Input

- Controllers go straight to the stream, off the main thread. A tap between two samples is still
  sent; unplugging sends one neutral state. Host rumble plays unless Rumble is off. Settings list
  controllers with player slot, battery and Test Vibration (Mac, Vision Pro, iPhone, iPad).
- **Xbox button.** Every controller's Xbox button goes to the Xbox while Starfold is in front. From
  macOS, iOS and visionOS 27 the player's game controller settings can tell the system to keep that
  button in every app, and Starfold cannot override it. While that is set and a controller is
  connected, Settings shows "Xbox button — macOS handles it instead of your Xbox." (the platform's
  name) with Open System Settings (Open Settings on Vision Pro, iPhone, iPad), and the connecting
  page shows "macOS is handling the Xbox button." with the same link. The stream's own Xbox Guide
  control always works. Apple TV hands the button to the Xbox only during play.
- Keyboard as controller (Mac; iPhone and iPad with a hardware keyboard) uses key positions: WASD left stick, IJKL right stick, arrows D-pad,
  Space A, Esc or Delete B, F X, R Y, Q LB, E RB, Z and C triggers, Return Menu, Tab View, Shift
  and V stick presses.
- Diagonals stay on the unit circle, opposite keys cancel, keyboard and controller on one player
  merge. Unbound keys and Command shortcuts pass through. Keys are released when the window loses
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

## Mac

- **Main window.** One window, 1180 × 760 by default: the sky, the cards and Continue Playing (up
  to 10). Toolbar: account menu leading, clock and Settings trailing, no visible title. Reopening
  brings back the same window. Library and game pages push inside it, with search in the toolbar.
- **Stream window.** Separate, 1280 × 720 by default (at least 640 × 360), full screen on its own,
  never restored at launch; only the picture and overlays. Quitting mid-stream ends the host
  session first, waiting at most 2 s.
- **Control bar.** Icon-only glass buttons: Xbox Guide, Statistics, Picture (MetalFX Upscaling,
  HDR Tone Mapping, Picture Mode, Sharpening, Buffer), Picture in Picture, Full Screen and
  Disconnect. It appears when the pointer moves or the picture starts and hides, with the pointer,
  after 3 s still. Tooltips name the shortcuts.
- **Stream menu.** Every control-bar command is in the menu bar:

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

- Sharpening has no menu item. The View menu has Refresh Library (⌘R).
- **Picture in Picture.** The stream window hides and the picture continues in a floating 16:9
  window on every Space. Back to Window or a double-click returns, Disconnect ends the stream, and
  a stream the host ends returns to the window. Controllers keep working with another app in front.
- **Menu bar extra.** A standard menu: gamertag (or a sign-in hint), Consoles (each starts a
  stream, "<console> · Playing <game>" when known), three Continue Playing games, controllers with
  battery, Open Starfold, Settings… (⌘,), Quit (⌘Q). Windows it opens come to the front; Settings
  can hide it.
- **Settings window.** Streaming: restart note, Quality, Cloud Gaming, Appearance (palette, menu
  bar icon). Picture: upscaling, sharpening, HDR, Picture Mode, statistics, Buffer. Controls:
  controllers, the Xbox button note, Rumble, keyboard toggle and key table. The gear on each home card opens it.

## Vision Pro

- **Tabs** (system vertical tab bar): Sign In and Settings signed out; Home, Cloud Gaming and
  Settings signed in. The account menu is in Home's toolbar.
- **Home:** console cards (Play, power button, Wi-Fi hint), then Continue Playing (up to 8); no
  cloud card. Cloud Gaming is its own tab, with search and a sort menu in the toolbar.
- **Stream window** replaces the main window (1280 × 720, 16:9); closing it ends the stream and
  brings the main window back. The connecting page is glass filling the same window.
- **Controls:** an ornament below the window, never over the picture, always visible while
  streaming: Xbox Guide, Statistics, Stream Options (Buffer and Sound), Disconnect. No picture
  mode, upscaling or sharpening.
- **Sound stage:** Follow Window (default) plays from the stream window; Direct Stereo plays
  straight to both ears; it switches at once. Sound is 48 kHz stereo, mixes with other apps,
  returns after interruptions and is released when the stream ends.
- **Settings tab:** Quality, Cloud Gaming, Picture (Buffer, statistics), Sound, Controllers. No
  palette.
- The low-latency streaming entitlement keeps Wi-Fi on the router's channel during a stream.

## Apple TV

- **Tabs** at the top: Home, Cloud Gaming, Settings, the system search tab.
- **Home:** focusable console and cloud cards; selecting a console starts it, a long press offers
  Wake Up or Turn Off; then a Recently Played shelf. **Cloud Gaming:** Continue Playing,
  Favorites, Recently Added, Leaving Soon and All Games by name; search only in its tab. Browsing
  and sign-in need only the remote.
- **Controller required.** A stream starts only with an extended game controller connected;
  otherwise "Connect a Controller" explains pairing, with Check Again, then Play. The remote never
  takes a player slot.
- **Stream:** full screen. Play/Pause opens a system sheet (Xbox Guide, Statistics, Picture Mode,
  Disconnect) that Back closes and no timer hides; Back during play ends the stream. The
  controller's Menu button always goes to the Xbox.
- Menus, game dialogs and leaving the app send the Xbox a neutral controller; a control held
  through them counts only after release. Going to the background ends the stream and session.
- **Settings:** Quality (no bitrate), Cloud Gaming, Picture (Buffer, statistics), Controllers,
  Account (switch, Add Account, Sign Out…), Appearance (palette). No upscaling, sharpening or HDR.
- **Top Shelf:** Continue Playing and Consoles rows, up to 10 items each, written by the app to the
  App Group container; the extension holds no token and fetches nothing. A game opens its page and
  Play starts it; a console starts a stream from Home. Signing out clears the rows; with nothing to
  show, a static image without text appears.

## iPhone and iPad

One app for both. Layout follows the size class of the space the app has, never the device, so iPad
Split View, Stage Manager and an unfolded iPhone Duo each get the layout that fits.

- **Tabs:** Home and Settings, signed in; a tab bar at the bottom on iPhone and at the top on iPad,
  no sidebar. The account menu is in Home's toolbar.
- **Signed out:** the welcome page, no tabs, Settings behind a gear (a sheet). On iPhone the app
  icon and three steps (sign in, pick a console or a cloud game, play) sit above a sign-in sheet
  fixed to the bottom; in landscape they blur behind a centred sign-in card. A wide iPad window
  puts the pitch beside the card; a narrower one stacks icon, steps and card in one centred column.
- **Home:** console cards, the Xbox Cloud Gaming row (three covers, availability, game count),
  then Continue Playing (up to 10). On iPhone one card fills the width and the cards page
  sideways; in landscape the card lies on its side, art left and details right. On iPad the cards
  are Mac-sized, in a row. With no cloud access the row says why and does not open.
- **Controller and keyboard:** Home starts on the first console card. A console card's select
  (A, Return or Space) plays; holding it, or touching and holding, offers Wake Up or Turn Off. The
  Cloud Gaming row opens the library, a Continue Playing game plays.
- **Cloud Gaming** opens from that row: the Mac's rows and All Games, a sort menu (Name, Recently
  Played) and a search field under the title. There is no search tab. With a controller, focus
  starts on the first game, not the search field; selecting a game opens its page, holding it
  offers Play.
- **Game page:** as on Mac; Touch shows among the input badges when the title has a touch layout.
  Focus starts on Play.
- **Settings:** Streaming (console, cloud and Cellular quality, Maximum Bitrate, Buffer, Game
  language), Display (Picture Mode, statistics, Color), Controls (Edit Layout and Touch haptics
  when touch controls exist, the controllers, the Xbox button note, Rumble, Keyboard as
  controller), Account (switch, Add Account, Sign Out…). No standing explanations: only a state the
  player must act on adds a line. Cellular quality shows only on a device with cellular data.
  Choices name the option alone, never a recommendation. On a wide iPad the rows keep a readable
  width.
- **Stream:** full screen, status bar and Home indicator hidden, system edge gestures deferred.
  iPhone streams in landscape only; iPad in any orientation and window size. The waiting and end
  pages are the Mac's.
- **Stream menu:** a handle at the top centre opens it; it dims after 3 s and hides while a
  controller is in use until a tap. The menu: Xbox Guide, Statistics, Disconnect, then Picture
  Mode, Buffer and Edit Touch Controls; tapping outside closes it. Game dialogs and keyboard
  prompts are sheets.
- **Leaving the app:** Control Center, a notification, the app switcher or a call sends a neutral
  controller, and a control held through it counts only after release; the stream keeps going.
  Going to the background (Home Screen, another app, Notification Center) mutes the sound and keeps
  the stream for as long as iOS lets the app run, at most a minute: coming back in time carries on
  with a fresh picture. Otherwise the session ends just before that time runs out, and coming back
  shows the ended stream with Close and Try Again.
  No Picture in Picture.
- **Sound** plays with the Ring/Silent switch on silent, pauses for calls and is released when the
  stream ends.
- **Cellular:** a stream that starts on cellular uses the Cellular quality ceiling for the whole
  session; the Xbox lowers resolution itself if bandwidth runs short.
- **Haptics** mark outcomes (a stream starting, ending or failing, sign-in, a power command) and
  direct manipulation (selecting, dropping or resetting in Edit Layout, a sort or stick choice, a
  favourite, the stream menu, a controller connecting), following the system's haptics setting.

### Touch controls

Starfold follows Xbox Cloud Gaming's own behaviour rather than inventing one.

- **When they show:** with no controller connected. Controller input (a keyboard counts) hides
  them; touching the screen or disconnecting the last controller brings them back. No setting.
- **Which layout:** a title with its own touch layout (Xbox Touch Adaptation Kit) gets it, in cloud
  and remote play, and the game decides when it shows, hides or changes. A layout needing anything
  Touch Controller cannot draw as the game meant it (throttles, touchpads, arcade groups, layer
  switches, turbo, toggle or pull buttons, several controls in a slot, centre controls, mouse
  output) falls back to the standard layout rather than leave a control out. Every other title gets
  the standard Xbox layout (Microsoft's `standard-controller.json`): left stick, D-pad, LB, LT and
  left stick click on the left; A, B, X, Y, RB, RT, right stick and its click on the right; View
  and Menu at the top right. A title that reads touch directly gets the standard layout until the
  Pointer report is specified in [streaming.md](streaming.md).
- **Look and feel:** Apple Touch Controller's system controls over the picture, neutral in every
  palette, at least 44 × 44 pt (View and Menu 28 × 28 pt), clear of the Dynamic Island and Home
  indicator. A press highlights at once and, with Touch haptics on, taps. On the standard layout
  each half of the screen is its stick's area, so a stick starts where the thumb lands. Buttons
  carry Xbox names, since Starfold cannot know what each does in a game.
- **Edit Layout** (Settings, and the stream menu) changes the standard layout only, per device and
  orientation: drag to move, select to resize, set the opacity, Reset restores the default. A close
  button sits at the top left and a pill at the top centre holds the hint (or the selected
  control's name), Opacity and Reset; a selected control gets a small inspector beside it, towards
  the middle of the screen. Both fade while a control is dragged.
- **Sticks** can show Always, On Touch (drawn under the thumb only while it is down) or Off (its
  half of the screen does nothing). Other controls keep their places, so turning a stick back on
  restores the layout. An On Touch or Off stick shows as a dashed outline in the editor; Size is
  unavailable while it is Off. The choice covers both orientations, Reset restores Always, and a
  title's own layout always shows its sticks.
- **Rumble** plays on the controller, or with only touch controls as iPhone haptics while Touch
  haptics is on.

### iPhone Duo

Built after iPhone and iPad are finished.

- Closed (outer display): the iPhone layout. Fully open: the layout the inner display's size class
  gives. Moving between displays or folding keeps the stream, its menu state and the player's
  place, without reconnecting.
- **Half folded:** the picture sits above the fold and the touch controls fill the half below it;
  nothing overlaps the picture. With a controller in use the lower half is empty except for the
  stream menu handle and, when on, statistics. The fold position comes from the system's reserved
  regions, never from the hinge angle.

## Out of scope

Other streaming services, mouse and keyboard passthrough (a keyboard only plays as a controller),
voice chat, notifications, analytics, light palettes, curved or immersive screens on Vision Pro, a
server of our own. Adding one changes this list first.
