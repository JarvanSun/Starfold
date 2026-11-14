# Product

What a player can do in Starfold. A behaviour not here is not built; a feature changes this file
before its code.

Starfold streams Xbox games to Mac, Apple Vision Pro, Apple TV, iPhone and iPad: remote play from
the player's consoles, and Xbox Cloud Gaming. It talks to Microsoft's and Xbox's services
directly; there is no Starfold server. The welcome screen says Starfold isn't affiliated with or
endorsed by Microsoft.

## Accounts

- Signed out, the welcome screen shows the sign-in at once: the code, the short link to enter it
  at and, on Mac and Apple TV, a QR code. A button (Mac, Vision Pro, iPhone, iPad) copies the code
  and opens the link with it filled in.
- The page says when it waits for the browser and when it signs in; then Home appears at once with
  placeholders. An expired code is replaced; a declined sign-in or an error shows the reason and a
  new code on request.
- Launch restores the last used account; tokens refresh before they expire. A rejected stored
  sign-in says so and offers to sign in again or not now.
- The account menu (avatar, gamertag, gamerscore) switches, adds (sign-in in a sheet that closes
  once signed in) and signs out accounts. Switching replaces profile, consoles, library and
  favourites.
- Signing out asks first, deletes the account's sign-in, saved library and console snapshots from
  the device, and moves to the next saved account or the welcome screen.

## Home and consoles

- Home shows the account's last saved library at once; the refresh replaces it.
- A card per console and, on Mac and Apple TV, one for Xbox Cloud Gaming; recently played cloud
  games underneath.
- A console card shows name, model and a power-state dot, a hint only (the reported state lags
  about a minute). On Wi-Fi it adds a Wi-Fi symbol that suggests a wired connection.
- Consoles with remote play on are listed; if there are none, the account's other consoles. None
  at all: an empty state that says to turn on Remote features, with Refresh. A failed list: the
  reason and Try Again.
- The list refreshes regularly while the app is active, and on return when it is stale.

| Console state | Power button | Effect |
|---|---|---|
| On | Turn Off | Sends the power-off command |
| Sleeping | Wake Up | Sends the wake command |
| Off (Energy-saving mode) | Disabled | Tooltip: remote wake needs Power mode set to Sleep; turn it on by hand, then press Play |

- A power command is done once the console accepts it; the app does not wait for the new state. A
  rejected or lost one says the console couldn't be reached and to check Remote features.
- **Cover:** the last frame of the console's last stream that showed a picture, else the game
  playing on (or last seen on) that console, else the model name; never a cloud or PC game. Last
  frames stay on the device, per account; Apple TV keeps none.

## Cloud Gaming

- Only games the account can play (Game Pass or free to play), with names and art from the
  Microsoft Store catalogue; a part of the catalogue that fails loses only its names and art.
- Without Game Pass the library falls back to free-to-play games and says so. Without cloud gaming
  (account or region) the card says it needs Game Pass in a supported region, not as an error.
- The cloud card shows its availability and game count, and opens the library.
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
- Waiting shows the name, one progress indicator, what is happening and Cancel; in the cloud
  queue, the estimated wait when known. Behind it: the game's art blurred, or the sky.
- Every wait times out or ends with Cancel. Closing the stream ends the host session without
  confirmation.
- The end page says how the stream ended (stopped, ended by the host, connection lost, failed,
  or on iPhone and iPad ended while away), with advice for a failure, and offers Close and Try
  Again.
- Game message boxes and text prompts appear as sheets and are answered there.
- The stream never pops up a network or quality notice.

### Settings that shape a stream

| Setting | Default | Where |
|---|---|---|
| Console quality | Automatic | All |
| Cloud quality | Automatic | All |
| Cellular quality | 720p | iPhone, iPad with cellular |
| Maximum bitrate | Automatic | Mac, Vision Pro, iPhone, iPad |
| MetalFX upscaling | On | Mac |
| Sharpening | Low | Mac |
| Picture Mode | Fit | Mac, Apple TV, iPhone, iPad |
| HDR tone mapping (only with an HDR screen) | Off | Mac |
| Buffer | Standard | All |
| Show statistics | Off | All |
| Game language (cloud) | System | All |
| Keyboard as controller | On | Mac, iPhone, iPad |
| Rumble | On | All |
| Touch haptics | On | iPhone |

- Automatic asks for 1080p; when bandwidth runs short the Xbox lowers the resolution mid-stream
  and keeps the frame rate. A fixed tier is a ceiling. Without Game Pass, cloud streams at 1080p,
  never 1440p.
- Cellular quality caps both qualities for the whole of a stream that starts on cellular data.
- Quality and bitrate are fixed per session: changing one mid-stream offers to restart the stream
  (Mac). Every other setting applies at once; a Buffer switch keeps queued frames.
- The stream is at most 1080p from a console and 1440p from the cloud; upscaling renders it at the
  picture's size on screen. HDR tone mapping spreads it over the screen's HDR range and says it is
  not native HDR.
- Touch haptics: a tap on a touch control and, with no controller, host rumble play on the device.

### Statistics

- First line: estimated latency (round trip + jitter buffer + decode + display), with a green,
  amber or red dot except on Apple TV. Then each figure the stream has a value for, including when
  the Xbox lowered the resolution.
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
- **Keyboard as controller** (Mac; iPhone and iPad with a hardware keyboard) goes by key position,
  with WASD as the left stick.
- Diagonals stay on the unit circle, opposite keys cancel, keyboard and controller on one player
  merge. Unbound keys and Command shortcuts pass through. Keys release when the window loses
  focus; every stream starts with none held.

### Errors and advice

A host error becomes one sentence on the step that fixes it (the cases are in
[streaming.md](streaming.md#errors)); only an unrecognised one is shown as is.

## Mac

- **Main window:** one window, reopened as the same window: the cards and Continue Playing. The
  toolbar holds the account menu, a clock and Settings, with no visible title. Library and game
  pages push inside it, with search in the toolbar.
- **Stream window:** separate, full screen on its own, never restored at launch; only the picture
  and overlays. Quitting mid-stream ends the host session first.
- **Control bar:** icon-only stream controls. It shows when the pointer moves or the picture
  starts, and hides with the pointer when it rests.
- **Menu commands:** every stream control is also a menu command, most with a shortcut.
- **Picture in Picture:** the stream window hides and the picture continues in a floating window
  on every Space. Back to Window or a double-click returns; Disconnect ends the stream; a
  stream the host ends returns to the window. Controllers keep working with another app in front.
- **Menu bar extra:** the account, consoles to stream (with the game playing when known), recent
  games, controllers with battery, and ways to open the app, Settings and quit. Windows it opens
  come to the front. Settings can hide it.
- **Settings window:** the stream settings, the palette and the menu bar icon. Each home card's
  gear opens it.

## Vision Pro

- **Tabs** (system vertical tab bar): Sign In and Settings signed out; Home, Cloud Gaming and
  Settings signed in. The account menu is in Home's toolbar.
- **Home:** console cards, then Continue Playing; no cloud card. Cloud Gaming has search and a
  sort menu in the toolbar.
- **Stream window** replaces the main window, connecting page included; closing it ends the
  stream and brings the main window back.
- **Controls:** an ornament below the window, never over the picture, always shown while
  streaming. No Picture Mode, upscaling or sharpening.
- **Sound stage:** Follow Window (default) plays from the stream window, Direct Stereo straight to
  both ears; switching is immediate. Sound is stereo, mixes with other apps, returns after
  interruptions and is released when the stream ends.
- **Settings tab:** the stream settings that apply here and the sound stage; no palette.
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
- **Stream:** full screen. Play/Pause opens a system sheet of stream controls that Back closes and
  no timer hides; Back during play ends the stream. The controller's Menu button always goes to
  the Xbox.
- Menus, game dialogs and leaving the app send the Xbox a neutral controller; a control held
  through them counts only after release. Going to the background ends the stream and session.
- **Settings:** the stream settings that apply here, the account and the palette. No bitrate,
  upscaling, sharpening or HDR.
- **Top Shelf:** Continue Playing and Consoles rows, from what the app last saved; the Top Shelf
  never signs in or fetches. A game opens its page and Play starts it; a console starts a stream
  from Home. Signing out clears the rows; with nothing to show, a static
  image without text appears.

## iPhone and iPad

One app for both. Layout follows the size class of the space the app has, never the device, so
iPad Split View, Stage Manager and an unfolded iPhone Duo each get the layout that fits.

- **Tabs** when signed in: Home and Settings, at the bottom on iPhone and the top on iPad; no
  sidebar. The account menu is in Home's toolbar.
- **Signed out:** the welcome page, no tabs, Settings in a sheet behind a gear. The app icon and
  the three steps to play sit with the sign-in, arranged for the space there is.
- **Home:** console cards, the Xbox Cloud Gaming row, then Continue Playing. A compact width pages
  through one card at a time; a regular width shows them in a row. With no cloud access the row
  says why and does not open.
- **Controller and keyboard:** Home starts on the first console card; select (A, Return or Space)
  plays, holding it or touching and holding offers Wake Up or Turn Off. The Cloud Gaming row opens
  the library; a Continue Playing game plays.
- **Cloud Gaming** opens from that row: the Mac's rows and All Games, a sort menu (Name, Recently
  Played) and a search field under the title; no search tab. With a controller, focus starts on
  the first game, not the search field; selecting a game opens its page, holding it offers Play.
- **Game page:** as on Mac, plus a Touch badge when the title has a touch layout. Focus starts on
  Play.
- **Settings:** the stream settings, the palette, the touch-control entries (only when touch
  controls exist) and the account. Only a state the player must act on adds a line; a choice names
  the option alone, never a recommendation. Cellular quality shows only on a device with cellular
  data.
- **Stream:** full screen, status bar and Home indicator hidden, system edge gestures deferred.
  iPhone streams in landscape only; iPad in any orientation and window size. The waiting and end
  pages are the Mac's.
- **Stream menu:** a handle at the top centre opens it; the handle dims when idle and hides while
  a controller is in use, until a tap. Tapping outside closes the menu.
- **Interruptions:** Control Center, a notification, the app switcher or a call keeps the stream
  going and sends the Xbox a neutral controller; a control held through it counts only after
  release.
- **Background:** going to the Home Screen, another app or Notification Center mutes the sound and
  keeps the stream for as long as iOS allows, at most a minute. Coming back in time carries on with
  a fresh picture; otherwise the session ends just before the time runs out, and coming back shows
  Stream ended while you were away with Close and Try Again.
- No Picture in Picture. **Sound** plays with the Ring/Silent switch on silent, pauses for calls
  and is released when the stream ends.
- **Haptics**, following the system's haptics setting, mark outcomes and direct manipulation.

### Touch controls

Starfold follows Xbox Cloud Gaming's own behaviour rather than inventing one.

- **When:** only with no controller connected; no setting. Controller input (a keyboard counts)
  hides them; touching the screen or disconnecting the last controller brings them back.
- **Layout:** a title with its own touch layout (Xbox Touch Adaptation Kit) gets it, in cloud and
  remote play, and the game decides when it shows, hides or changes. Every other title gets the
  standard Xbox layout ([streaming.md](streaming.md#touch-iphone-ipad)).
- A title layout falls back to the standard one, rather than leave a control out, when Touch
  Controller cannot draw it as the game meant. A title that reads touch directly gets the standard
  layout until Pointer reports are specified in [streaming.md](streaming.md).
- **Look and feel:** Apple Touch Controller's system controls over the picture. A press highlights
  at once and, with Touch haptics on, taps. On the standard layout each half of the screen is its
  stick's area, so a stick starts where the thumb lands. Buttons carry Xbox names, since Starfold
  cannot know what each does in a game.
- **Edit Layout** (Settings and the stream menu) changes the standard layout only, per device and
  orientation: drag to move, select to resize, set the opacity; Reset restores the default.
- **Sticks** show Always, On Touch (drawn under the thumb only while it is down) or Off (its half
  of the screen does nothing). Other controls keep their places, so turning a stick back on
  restores the layout. In the editor an On Touch or Off stick is a dashed outline, and Size is
  unavailable while it is Off. The choice covers both orientations, Reset restores Always, and a
  title's own layout always shows its sticks.

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
