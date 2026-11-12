# Product

What a player can do in Starfold and the rules each feature follows. A behaviour that is not here
is not built; a feature changes this file before its code.

Starfold streams Xbox games to a Mac, an Apple Vision Pro and an Apple TV: remote play from the
player's own consoles, and Xbox Cloud Gaming. It talks to Microsoft's and Xbox's services directly;
there is no Starfold server. User-facing text names the app only by its display name
(`AppInfo().displayName`), in English and Simplified Chinese, and the welcome screen says Starfold
isn't affiliated with or endorsed by Microsoft.

## Accounts

- **Device code.** Signed out, the welcome screen shows the sign-in at once, with no button to find
  first: the code in boxes, "or enter the code at microsoft.com/link", and a QR code on Mac and
  Apple TV (not on Vision Pro: a phone can't scan a code inside the headset). Open Link (Mac) or
  Sign In (Vision Pro) copies the code and opens the link with the code filled in.
- "Waiting for sign in…" while polling, "Signing in…" after the browser step; then Home appears at
  once with placeholders, without waiting for the library. A code that runs out is replaced; a
  declined sign-in or an error shows the reason and Get a New Code.
- Launch restores the last used account. Tokens refresh before they expire, once for any number of
  concurrent requests. A rejected stored sign-in shows "Sign-in expired" with Sign In or Not Now.
- **Multiple accounts.** The account menu (avatar, gamertag, gamerscore) has Switch Account,
  Add Account… (the sign-in panel in a sheet, closing itself once signed in) and Sign Out….
  Switching replaces profile, consoles, library and favourites.
- Sign Out asks "Sign out of <gamertag>?" first, then moves to the next saved account, or to the
  welcome screen after the last one. The account's keychain entry, library cache and console
  snapshots are deleted.

## Home and consoles

- Opening the app shows the last library this account saw, at once; the refresh replaces it.
- Home has one card per console and, on Mac and Apple TV, one for Xbox Cloud Gaming, with recently
  played cloud games underneath. Loading shows placeholder cards; an empty or failed state explains
  itself in one line and offers one action.
- Consoles with remote play on are listed by name with their model and a power-state dot. The dot
  is a hint (the reported state lags by about a minute); its words go to VoiceOver. A console on
  Wi-Fi shows a Wi-Fi symbol: "On Wi-Fi. A wired connection is steadier."
- If no console has remote play on, the account's other consoles are listed anyway. None at all:
  "No consoles", "Turn on Remote features on your Xbox." and Refresh. A failed list: "Couldn't load
  consoles", the reason and Try Again.
- While the app is active the list refreshes every 30 s; returning refreshes it at once if it is
  older than 10 s.

| Console state | Power button | Effect |
|---|---|---|
| On | Turn Off | Sends the power-off command |
| Sleeping | Wake Up | Sends the wake command |
| Off (Energy-saving mode) | Disabled | Tooltip: remote wake needs Power mode set to Sleep; turn it on by hand, then press Play |

- A power command is done once the console accepts it; the app neither waits for nor second-guesses
  the new state. A rejected or lost command shows "Couldn't reach <console>" with "Check that Remote
  features are on, then try again."
- **Snapshots.** When a console stream that showed a picture ends, its last frame becomes the
  card's cover. Cover order: last frame, else the game playing on (or last seen on) that console,
  else the model name; a game played in the cloud or on a PC never appears on a console card.
  Snapshots are JPEGs on the device, per account, deleted on sign-out. Apple TV keeps none.

## Cloud Gaming

- Only games the account can play (Game Pass or free to play), with names and art from the
  Microsoft Store catalogue, fetched in parallel batches; a failed batch loses only names and art.
- Without Game Pass the library falls back to free-to-play games and says so. An account or region
  without cloud gaming sees "Cloud gaming isn't available" and "Needs Xbox Game Pass in a supported
  region.", not an error. The cloud card shows Available, Free to play, Unavailable or Loading…,
  the number of games and Browse Games.
- **Rows**, each shown only when it has games: Continue Playing, Favorites, Recently Added and
  Leaving Soon (with a "Leaving" badge). Curated rows contain only playable games.
- **All Games** below with its count, sorted by Name or Recently Played (played games first, most
  recent first, the rest by name); the choice is remembered.
- **Search** matches the name or publisher, ignoring case and surrounding spaces. While searching
  the rows hide and the grid becomes Results; no match shows the system's no-results view.
- **Game page:** art, title, publisher, input badges, Play and a favourite heart, then About, genres,
  developer, release date and screenshots. Favourites are per account and survive relaunch.

## Streaming

- Play on a card, a tile, a game page or the menu bar opens the stream window and starts the
  session. Playing a target that is already starting or playing only brings its window forward; it
  never asks the host for a second session.
- Waiting shows the name, one progress indicator, "Connecting…" and Cancel; in the cloud queue,
  "In line — about N minutes" or "Waiting in line…". Behind it: the game's art blurred, or the sky.
- Every wait times out or ends with Cancel. Closing the stream window ends the host session, with no
  confirmation. The end page says Stream ended, Session ended, Connection lost or Connection failed,
  with advice for a failure, and offers Close and Try Again.
- Message boxes and text prompts from the game appear as sheets and are answered there.

### Settings that shape a stream

| Setting | Options | Default | Where |
|---|---|---|---|
| Console quality | Automatic, 720p, 1080p, 1080p High Bitrate | Automatic | All |
| Cloud quality | Automatic, 720p, 1080p, 1440p (Game Pass Ultimate) | Automatic | All |
| Maximum bitrate | Automatic, 10–80 Mbps | Automatic | Mac, Vision Pro |
| MetalFX upscaling | On, Off | On | Mac |
| Sharpening | Off to High | Low | Mac |
| Picture Mode | Fit; Fill (crops the edges); Scale (stretches to the view's shape) | Fit | Mac, Apple TV |
| HDR tone mapping | On, Off; shown only with an HDR screen connected | Off | Mac |
| Buffer | Standard, Low Latency | Standard | All |
| Show statistics | On, Off | Off | All |
| Game language (cloud) | System or one of 12 languages | System | All |
| Keyboard as controller, Rumble | On, Off | On | Keyboard: Mac; Rumble: all |

- Automatic asks for 1080p. When bandwidth runs short the Xbox lowers the resolution mid-stream and
  keeps the frame rate, without reconnecting; fixed tiers are ceilings. A free-to-play account never
  asks for cloud 1440p (the host would end the session) and streams at 1080p.
- Quality and bitrate are fixed for a session: changing one mid-stream shows "Restart the stream to
  use the new quality." with Restart Stream (Mac). Every other setting applies at once.
- Upscaling renders to the picture's pixel size on screen, up to 4K and beyond; the stream itself is
  at most 1080p from a console and 1440p from the cloud.
- HDR tone mapping spreads the SDR stream over the screen's HDR range (reference white 203 nits,
  highlights about 600 nits). It is not native HDR and says so.
- Frames are shown by the host's capture time. Standard buffers only what recent hiccups need (a few
  milliseconds on a steady network, at most 120 ms); Low Latency at most 40 ms. Switching mid-stream
  keeps the queued frames. On a ProMotion or other high-refresh Mac screen the display runs at 120 Hz.

### Statistics

- Top-leading overlay. First line: estimated latency (round trip + jitter buffer + decode +
  display); on Mac and Vision Pro with a green (under 50 ms), amber (under 90 ms) or red dot.
- Then each line the stream has a value for:
  - **Mac:** resolution and codec (marked Automatic), upscaled size, SDR → HDR tone mapping,
    "Lowered from <tier>", frame rate, bitrate, network path (Local network, Internet or Relay;
    Wi-Fi or Ethernet), round trip, decode, jitter buffer, display, packet loss.
  - **Vision Pro:** resolution (marked Automatic), "Lowered from <tier>", frame rate, bitrate,
    round trip, decode, jitter buffer, packet loss.
  - **Apple TV:** resolution, frame rate, bitrate, codec, "Lowered from <tier>".
- The stream never pops up a network or quality notice; the statistics are where to look.
- Copy Statistics (Mac) copies the figures as English plain text, noting that controller input and
  the host's capture and encode are not included.

### Input

- Controllers go straight to the stream, off the main thread. A tap between two samples is still
  sent; unplugging sends one neutral state. Host rumble plays on the controller unless Rumble is off.
  Settings list controllers with player slot, battery and Test Vibration (Mac, Vision Pro).
- Keyboard as controller (Mac) uses key positions, so any layout works: WASD left stick, IJKL right
  stick, arrows D-pad, Space A, Esc or Delete B, F X, R Y, Q LB, E RB, Z and C triggers, Return Menu,
  Tab View, Shift and V stick presses.
- Diagonals stay on the unit circle, opposite keys cancel, and keyboard and controller on one player
  merge. Unbound keys and Command shortcuts pass through. Keys are released when the window loses
  focus, and every stream starts with none held.

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

- **Main window.** One window, 1180 × 760 by default: the sky, the cards and Continue Playing (up to
  10). Toolbar: account menu leading, clock and Settings trailing, no visible title. Opening it again
  brings back the same window. The library and game pages push inside it, with search in the toolbar.
- **Stream window.** Separate, 1280 × 720 by default (at least 640 × 360), full screen on its own,
  never restored at launch; only the picture plus overlays. Quitting mid-stream ends the host session
  first, waiting at most 2 s.
- **Control bar.** Icon-only glass buttons: Xbox Guide, Statistics, Picture (MetalFX Upscaling, HDR
  Tone Mapping, Picture Mode, Sharpening, Buffer), Picture in Picture, Full Screen (Exit Full Screen
  however full screen was entered) and Disconnect. It appears when the pointer moves or the picture
  starts and hides, with the pointer, after 3 s without movement. Tooltips name the shortcuts.
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

- Sharpening has no menu item; it is in the control bar's Picture menu and Settings. The View menu
  has Refresh Library (⌘R).
- **Picture in Picture.** The stream window hides and the whole picture continues in a floating 16:9
  window on every Space. Back to Window or a double-click returns, Disconnect ends the stream, and a
  stream the host ends returns to the window. Controllers keep working with another app in front.
- **Menu bar extra.** A standard menu: gamertag (or a sign-in hint), Consoles (each starts a stream,
  "<console> · Playing <game>" when known), three Continue Playing games, controllers with battery,
  Open Starfold, Settings… (⌘,), Quit (⌘Q). Windows it opens come to the front; Settings can hide it.
- **Settings window.** Streaming: restart note, Quality, Cloud Gaming, Appearance (palette, menu bar
  icon). Picture: upscaling, sharpening, HDR, Picture Mode, statistics, Buffer. Controls: controllers,
  Rumble, keyboard toggle and key table. The gear on each home card opens it.

## Vision Pro

- **Tabs** in the system's vertical tab bar: Sign In and Settings when signed out; Home, Cloud
  Gaming and Settings when signed in. The account menu is in Home's toolbar.
- **Home:** console cards (Play, power button, Wi-Fi hint), then Continue Playing (up to 8); no
  cloud card. Cloud Gaming is its own tab, with search and a sort menu in the toolbar.
- **Stream window.** It replaces the main window (1280 × 720, 16:9); closing it ends the stream and
  brings the main window back. The connecting page is glass filling the same window, so the size
  holds when the picture arrives.
- **Controls:** an ornament hangs below the window, never over the picture, always visible while
  streaming: Xbox Guide, Statistics, Stream Options (Buffer and Sound) and Disconnect. No picture
  mode, upscaling or sharpening.
- **Sound stage:** Follow Window (default) plays from the stream window; Direct Stereo plays
  straight to both ears, like headphones; it switches at once. Sound is 48 kHz stereo, mixes with
  other apps, returns after interruptions and is released when the stream ends.
- **Settings tab:** Quality, Cloud Gaming, Picture (Buffer, statistics), Sound, Controllers. No
  palette choice.
- On device the app uses the low-latency streaming entitlement, so the system keeps Wi-Fi on the
  router's channel during a stream.

## Apple TV

- **Tabs** at the top: Home, Cloud Gaming, Settings and the system search tab.
- **Home:** focusable console and cloud cards; selecting a console starts it, a long press offers
  Wake Up or Turn Off. Then a Recently Played shelf. **Cloud Gaming:** Continue Playing,
  Favorites, Recently Added, Leaving Soon and All Games by name; search is only in its tab.
  Browsing and sign-in need only the remote.
- **Controller required.** A stream starts only with an extended game controller connected;
  otherwise "Connect a Controller" explains pairing, with Check Again, then Play. The remote never
  takes a player slot.
- **Stream:** full screen in the one window. Play/Pause opens a system sheet (Xbox Guide,
  Statistics, Picture Mode, Disconnect) that Back closes and no timer hides; Back during play ends
  the stream. The controller's Menu button always goes to the Xbox.
- Menus, game dialogs and leaving the app send the Xbox a neutral controller; a control held
  through them counts only after release. Going to the background ends the stream and its session.
- **Settings:** Quality (no bitrate), Cloud Gaming, Picture (Buffer, statistics), Controllers,
  Account (switch, Add Account, Sign Out…), Appearance (palette). No upscaling, sharpening or HDR.
- **Top Shelf:** Continue Playing and Consoles rows, up to 10 items each, written by the app to a
  shared App Group container; the extension holds no token and fetches nothing. A game opens its
  page and Play starts it; a console starts a stream from Home. Signing out clears the rows; with
  nothing to show, a static image without text appears.

## Out of scope

iPhone and iPad, other streaming services, touch controls, mouse and keyboard passthrough, voice
chat, notifications, analytics, light palettes, curved or immersive screens on Vision Pro, and a
server of our own. Adding one changes this list first.
