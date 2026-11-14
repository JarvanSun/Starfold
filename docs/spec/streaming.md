# Streaming Protocol

How a stream reaches a console (xHome) or a cloud machine (xCloud): sign-in, the gssv session REST
API, WebRTC signalling and the four data channels. Values are what the servers expect; change this
file before you change one. Which package owns which part is in [architecture.md](architecture.md).

- JSON is sent with `.withoutEscapingSlashes`.
- Xbox dates carry up to 7 fractional digits; trim them to milliseconds.
- Keep the body of a failed response: these services explain most failures there.

## Sign-in and tokens

OAuth device-code grant (RFC 8628) against Microsoft consumer accounts. No redirect, no signed
request.

| Constant | Value |
|---|---|
| Client id (`STARFOLD_MICROSOFT_CLIENT_ID`) | `1f907974-e22b-4810-a9de-d9647380c97e`, the xbox.com web player's; the transfer token is only known to work with it |
| Scope | `xboxlive.signin openid profile offline_access` |
| Form bodies | `application/x-www-form-urlencoded`, every character outside `A-Z a-z 0-9 - . _ ~` percent-encoded |

| Step | Request | Notes |
|---|---|---|
| Code | `POST https://login.microsoftonline.com/consumers/oauth2/v2.0/devicecode` with `client_id`, `scope`, `response_type=device_code` | Returns `device_code`, `user_code`, `verification_uri`, `expires_in`, `interval`. Without `verification_uri_complete`, open `<verification_uri>?otc=<user_code>`. |
| Poll | `POST …/consumers/oauth2/v2.0/token` with `grant_type=urn:ietf:params:oauth:grant-type:device_code`, `client_id`, `device_code` | Every `interval` s (5 if absent) until `expires_in` passes. `authorization_pending`: keep polling; `slow_down`: add 5 s; `expired_token` → `DeviceCodeError.expired`; `authorization_declined` / `access_denied` → `.declined`; others → `.server`. |
| Refresh | Same URL, `grant_type=refresh_token`, `refresh_token`, `scope` | Keep the old refresh token if none is returned. HTTP 400 / 401 → `XboxAccountError.signInRequired`. |
| User token | `POST https://user.auth.xboxlive.com/user/authenticate` | `{"Properties":{"AuthMethod":"RPS","RpsTicket":"d=<msa access token>","SiteName":"user.auth.xboxlive.com"},"RelyingParty":"http://auth.xboxlive.com","TokenType":"JWT"}` |
| XSTS | `POST https://xsts.auth.xboxlive.com/xsts/authorize` | `{"Properties":{"SandboxId":"RETAIL","UserTokens":["<user token>"]},"RelyingParty":"<rp>","TokenType":"JWT"}` |
| Streaming token | `POST https://<offering>.gssv-play-prod.xboxlive.com/v2/login/user` | `{"token":"<gssv XSTS>","offeringId":"<offering>"}` |
| Transfer token | `POST https://login.live.com/oauth20_token.srf` with `client_id`, `grant_type=refresh_token`, `refresh_token`, `scope=service::http://Passport.NET/purpose::PURPOSE_XBOX_CLOUD_CONSOLE_TRANSFER_TOKEN` | The v2 refresh token is accepted. `access_token` is the transfer token. Fetch it per stream; never cache it. |

- User token and XSTS headers: `x-xbl-contract-version: 1`, `Cache-Control: no-cache`, JSON
  `Content-Type` and `Accept`, `Origin: https://www.xbox.com`, `Referer: https://www.xbox.com/`.
- Streaming login and transfer token: `Cache-Control: no-store, must-revalidate, no-cache`; the
  login also `x-gssv-client: XboxComBrowser`.
- XSTS replies carry `DisplayClaims.xui[0]`: `uhs` (user hash), and for the web token `gtg`
  (gamertag) and `xid` (xuid).

| Relying party | Token | Used for |
|---|---|---|
| `http://xboxlive.com` (no trailing slash) | Web token, `Authorization: XBL3.0 x=<uhs>;<token>` | Profile, presence, title history, xccs console list and power commands |
| `http://gssv.xboxlive.com/` (trailing slash required) | gssv token | Only the streaming login |

| Offering (`StreamingOffering`) | Id | Use |
|---|---|---|
| `.home` | `xhome` | Console remote play |
| `.cloud` | `xgpuweb` | Cloud gaming with Game Pass |
| `.cloudFreeToPlay` | `xgpuwebf2p` | Free-to-play cloud titles without Game Pass |

- The streaming login returns `gsToken`, `durationInSeconds` (usually 14400; expiry = receipt +
  duration), `market` and `offeringSettings.regions[]` (`name`, `baseUri`, `isDefault`). Use the
  `isDefault` region, else the first.
- 403 `OfferingAccessDenied`: the account cannot use that offering. Cloud tries `xgpuweb`, then
  `xgpuwebf2p`, and remembers the one that works in `StoredAccount.cloudOffering`, forgetting it
  when it fails. None working → `XboxAccountError.cloudGamingUnavailable`.
- Reuse a token while more than 60 s remain. The refresh token rotates, so concurrent callers
  share one refresh.
- `StoredAccount` is JSON in the Keychain under `account.<xuid>`. Only its MSA token is essential;
  the Xbox and streaming tokens are caches; the user token lives in memory only.

## Consoles and power

| Request | Auth | Notes |
|---|---|---|
| `GET <xhome baseUri>/v6/servers/home` | Bearer, `X-MS-Device-Info` | `results[]`: `serverId`, `deviceName`, `consoleType`, `powerState`, `outOfHomeWarning`, `wirelessWarning`. Only consoles with remote play on. |
| `GET https://xccs.xboxlive.com/lists/devices?queryCurrentDevice=false&includeStorageDevices=true` | Web token, contract 2 | `result[]`: `id`, `name`, `consoleType`, `powerState`. Every console; shown when the gssv list is empty. |
| `POST https://xccs.xboxlive.com/commands` | Web token, contract 4, `skillplatform: RemoteManagement` | `{"destination":"Xbox","type":"Power","command":"WakeUp" or "TurnOff","sessionId":"<new uuid>","sourceId":"com.microsoft.smartglass","parameters":[],"linkedXboxId":"<serverId>"}`. 10 s timeout. `status.errorCode` other than `OK` → `XboxLiveClient.CommandRejected`. |

xccs calls also send `x-xbl-client-name: XboxApp`, `x-xbl-client-type: UWA`,
`x-xbl-client-version: 39.39.22001.0`. `OK` is the only prompt confirmation of a power command;
the lists show the new state about a minute later.

## Session start

Every gssv call sends `Authorization: Bearer <gsToken>`, `Accept: application/json` and
`X-Gssv-Client: XboxComBrowser`, plus `Content-Type: application/json` when it has a body. On 401
or 403, fetch a new streaming token and retry once. Signalling and keepalive use the token; media
does not.

`POST <baseUri>/v5/sessions/{home|cloud}/play` with header `X-MS-Device-Info` and body:

```json
{ "clientSessionId": "", "titleId": "<cloud titleId, else empty>", "systemUpdateGroup": "",
  "serverId": "<console serverId, else empty>", "fallbackRegionNames": [],
  "settings": { "nanoVersion": "V3;WebrtcTransport.dll", "enableTextToSpeech": false,
    "highContrast": 0, "locale": "<game language, e.g. en-US>", "useIceConnection": false,
    "timezoneOffsetMinutes": <local offset>, "sdkType": "web", "osName": "<osName>",
    "enableOptionalDataCollection": false } }
```

`X-MS-Device-Info` is this JSON; the display size never caps the stream:

```json
{ "appInfo": { "env": { "clientAppId": "www.xbox.com", "clientAppType": "browser",
    "clientAppVersion": "29.9.35", "clientSdkVersion": "10.6.8", "httpEnvironment": "prod",
    "sdkInstallId": "" } },
  "dev": { "hw": { "make": "Microsoft", "model": "unknown", "platformType": "desktop",
      "sdktype": "web" },
    "os": { "name": "<osName>", "ver": "22631.2715", "platform": "desktop" },
    "displayInfo": { "dimensions": { "widthInPixels": 4096, "heightInPixels": 2160 },
      "pixelDensity": { "dpiX": 1, "dpiY": 1 } },
    "browser": { "browserName": "edge", "browserVersion": "140.0.3485.66" } } }
```

The host picks the quality tier from `osName`, sent in both `dev.os.name` and `settings.osName`:

| `StreamQuality` | `osName` | Stream | Announced size until the host reports its own |
|---|---|---|---|
| `.standard` | `android` | 720p | 1280×720 |
| `.high` | `windows` | 1080p | 1920×1080 |
| `.highest` | `tizen` | Console: 1080p at a higher bitrate. Cloud: 1440p where the title supports it. | 1920×1080 |

A free-to-play cloud account never asks for more than `.high`. The reply (200 or 202) carries
`sessionPath` (no leading slash); the session URL is `<baseUri>/<sessionPath>`, or `sessionPath`
itself when it starts with `http`. Paths below are relative to it.

## Provisioning and queue

Poll `GET state`, building the peer and its offer meanwhile.

| `state` | Action |
|---|---|
| `Provisioning` | Keep polling. |
| `WaitingForResources` | Cloud queue. Once, read `GET <baseUri>/v1/waittime/<titleId>` (`estimatedTotalWaitTimeInSeconds`) and report `StreamPhase.queued(estimatedWait:)`. |
| `ReadyToConnect` | Cloud only. Once, `POST connect` with `{"userToken":"<transfer token>"}`, then keep polling. |
| `Provisioned` | Go on to SDP. |
| `Failed` | Throw `GSSVSessionError.failed(code:message:)` from `errorDetails`. |
| anything else | Keep polling. |

- Poll delay: 100 ms for the first 2 s, 250 ms until 10 s, 500 ms until 30 s, then 1 s. The SDP
  and ICE polls use the same schedule.
- Timeout: 90 s for a console, 15 minutes for cloud. Expiry throws
  `GSSVSessionError.timedOut("state")`.
- `GET configuration` (in parallel with SDP) gives `keepAlivePulseInSeconds`. The keepalive
  interval is that value clamped to 5…30 s, or 20 s when absent.

## SDP and ICE

Build the peer in this order: audio transceiver `sendrecv`, video `recvonly`, the four data
channels, then the offer.

- Configuration: unified plan, `maxBundle`, RTCP mux required, gather once, link-local networks
  and TCP candidates off, DSCP on, fast audio jitter-buffer accelerate on. ICE servers by default:
  `stun:stun.l.google.com:19302` and `stun:stun1.l.google.com:19302`. No TURN.
- Video codec order: H.264 `profile-level-id` `4d…` (Main), `42e…` (constrained baseline),
  `420…` (baseline), other H.264, other codecs, RTX and RED last. The host is H.264 only. The
  decoder factory adds Main `4d001f`; without a `4d` entry the host answers with constrained
  baseline.
- The offer is munged before it is set locally and sent; the answer is applied unmodified. The
  Opus `a=fmtp` line loses any `stereo`, `sprop-stereo`, `minptime` and `useinbandfec` and gains
  `stereo=1;minptime=10;useinbandfec=1`. With a bitrate cap, `b=AS:<kbps>` goes in the video
  section after any `i=` and `c=` lines, replacing an existing `b=AS`.

`POST sdp`, then poll `GET sdp` (30 s timeout):

```json
{ "messageType": "offer", "sdp": "<munged offer>",
  "configuration": {
    "chatConfiguration": { "bytesPerSample": 2, "expectedClipDurationMs": 20,
      "format": { "codec": "opus", "container": "webm" }, "numChannels": 1,
      "sampleFrequencyHz": 24000 },
    "chat": { "minVersion": 1, "maxVersion": 1 }, "control": { "minVersion": 1, "maxVersion": 3 },
    "input": { "minVersion": 1, "maxVersion": 8 },
    "message": { "minVersion": 1, "maxVersion": 1 } } }
```

- Not ready: HTTP 204 or an empty body. Ready:
  `{"exchangeResponse":"<JSON string>","errorDetails":{…}}` (an object instead of the string is
  accepted). A non-null `errorDetails.code`, or an inner `status` other than `success`, throws
  `GSSVSessionError.failed`.
- The inner object has `sdp` and the negotiated `chat`, `control`, `input` and `message` versions
  (1 when missing). Input stays at most 8: input v9 and the `reliableinput` / `unreliableinput`
  channels are not implemented.

Local candidates are sent once, not trickled. Gathering ends at `complete`, or 300 ms after the
last candidate once a `typ srflx` exists, or after 3 s.

- `POST ice` with
  `{"messageType":"iceCandidate","candidate":[{"candidate":"candidate:…","sdpMid":"0","sdpMLineIndex":0}]}`,
  then poll `GET ice` (30 s timeout). `exchangeResponse` parses to an array of
  `{candidate, sdpMid, sdpMLineIndex}`; host candidates carry an `a=` prefix and `sdpMLineIndex`
  is a string. Everything is bundled on mid `0`; the console listens on UDP 9002.
- Strip `a=`; drop `end-of-candidates` and any candidate with both ` udp ` and `tcptype`.
- A Teredo address (field 5, `2001:0000:…`) gains two candidates before the original:
  `candidate:10 1 UDP 1 <ipv4> 9002 typ host` and `candidate:11 1 UDP 1 <ipv4> <port> typ host`,
  where port = group 6 XOR `0xFFFF` and ipv4 = groups 7–8 XOR `0xFFFFFFFF`. This lets
  out-of-home console streams connect without IPv6.
- The peer must reach `connected` within 20 s, else `StreamError.connectionTimedOut`.

## Data channels

The client creates all four in-band (no pre-negotiated ids), ordered and reliable. Everything is
sent binary; JSON is UTF-8. Strip NUL bytes from incoming data before parsing.

| Label | Protocol | Content |
|---|---|---|
| `input` | `1.0` | Binary packets, little-endian |
| `control` | `controlV1` | JSON `{"message": <name>, …}` |
| `message` | `messageV1` | JSON envelopes |
| `chat` | `chatV1` | Opened, nothing sent; incoming only logged |

Start-up:

1. `message` opens → send `Handshake`. `control` opens → send a keyframe request. Both media
   tracks received → another keyframe request.
2. First `HandshakeAck` → on control `authorizationRequest`; on input `ClientMetadata`; on
   message the six configuration messages; on control `gamepadChanged {0, false}`.
3. 500 ms later → `gamepadChanged {0, true}`, then input starts with slot 0 announced. The host
   shows a controller only after this pair.

| Control message | Fields |
|---|---|
| `authorizationRequest` | `accessKey: "4BDB3609-C1F1-4195-9B37-FEFF45DA8B8E"` (constant) |
| `gamepadChanged` | `gamepadIndex` 0…3, `wasAdded`. A slot is announced before records use it. |
| `videoKeyframeRequested` | `ifrRequested: false`. At start-up and when the app asks (`StreamController.requestKeyframe()`), never periodically. |

Message envelope: `type`, `id` (lowercase UUID; replies reuse the id they answer), `target`,
`content` (payload as a JSON string; a raw object is accepted on receipt), `cv`
(`<uuid without dashes>.<n>`, n counting up per channel). Handshake:
`{"type":"Handshake","version":"messageV1","id":…,"cv":…}`.

| Configuration message (`type: Message`, in this order) | `content` |
|---|---|
| `/streaming/systemUi/configuration` | `{"version":[0,2,0],"systemUis":[10,19]}` (10 virtual keyboard, 19 message dialog) |
| `/streaming/properties/clientappinstallidchanged` | `{"clientAppInstallId":"<uuid, stable per install>"}` |
| `/streaming/characteristics/orientationchanged` | `{"orientation":0}` |
| `/streaming/characteristics/touchinputenabledchanged` | `{"touchInputEnabled":false}`; `true` with [touch](#touch-iphone-ipad) |
| `/streaming/characteristics/clientdevicecapabilities` | `{}`; with touch, `{"maxTouchBundleLayoutVersion":…,"maxTouchBundleManifestVersion":…}` (`4.1.0.0`, `2.0.0.0` today) |
| `/streaming/characteristics/dimensionschanged` | `horizontal`, `vertical`, `preferredWidth`, `preferredHeight` = announced size; `safeAreaLeft`/`Top` 0, `safeAreaRight`/`Bottom` = width/height; `supportsCustomResolution: true` |

| Incoming target (`Message` or `TransactionStart`) | Handling |
|---|---|
| `/streaming/systemUi/messages/ShowMessageDialog` | `TitleText`, `ContentText`, non-empty `CommandLabel1…3`, `DefaultIndex`, `CancelIndex`. Reply `TransactionComplete` with `{"Result": <0-based button index>}`. |
| `/streaming/systemUi/messages/ShowVirtualKeyboard` | `TitleText`, `DescriptionText`, `DefaultText`, `MaxLength`. Reply `TransactionComplete` with `{"Text": …}`, or `ReceiverCancel` on cancel. |
| `/streaming/sessionLifetimeManagement/serverInitiatedDisconnect` | Reply `TransactionComplete` with `{}` if a transaction, then stop with `.hostEnded`. |
| `/streaming/properties/titleinfo` | `titleid` (a hex string kept as sent; a number becomes uppercase hex) and `focus` (true when absent), keys matched in any case. No reply. Ignored without a title id. |
| `/streaming/touchcontrols/…` | The five targets in [Touch](#touch-iphone-ipad). Any other target here: `ReceiverCancel` for a transaction, else ignored. |
| anything else | Reply `{"type":"Unhandled","id","target","cv"}`. |

A `SenderCancel` withdraws an open dialog, with no reply.

## Input encoding

A client packet is a 14-byte header, then the present sections in the order Metadata, Gamepad.
Each section starts with a u8 count (at most 255 records). All integers are little-endian.

| Offset | Size | Field |
|---|---|---|
| 0 | u16 | Report-type flags: 1 Metadata, 2 Gamepad, 8 ClientMetadata, 16 ServerMetadata (S→C), 128 Vibration (S→C) |
| 2 | u32 | Sequence: 0 for ClientMetadata, then 1, 2, …; advances only when a send succeeds |
| 6 | f64 | Timestamp in ms, monotonic: `(CACurrentMediaTime() − stream start) × 1000` |

`ClientMetadata` is exactly 15 bytes: the header with flags 8 and sequence 0, then u8
`maxTouchPoints` (0 without touch). Pointer, mouse and keyboard sections are never sent; the
keyboard and the touch controls play as a gamepad.

| Record | Size | Layout (relative offset: type field) |
|---|---|---|
| Metadata | 28 | 0 u32 RTP timestamp of the frame; 4 u32 first packet arrival; 8 u32 submitted to decoder; 12 u32 decoded; 16 u32 rendered; 20 u32 packet time; 24 u32 date now |
| Gamepad | 23 | 0 u8 slot; 1 u16 buttons; 3 i16 left X; 5 i16 left Y; 7 i16 right X; 9 i16 right Y; 11 u16 left trigger; 13 u16 right trigger; 15 u32 physical physicality; 19 u32 virtual physicality (touch controls; else 0) |

- One Metadata record per decoded frame. All four times are when the decoded frame reached the
  app, not a paced display time (the host lowers resolution when frame times grow). Packet time
  and date now are the header timestamp truncated to u32. At most 29 records wait; older ones drop.
- Sticks: `trunc(clamp(v, −1, 1) × 32767)`, up and right positive (GameController's +Y is up; no
  negation). Triggers: `trunc(clamp(t, 0, 1) × 65535)`.
- Buttons (u16): `0x0002` Nexus, `0x0004` Menu, `0x0008` View, `0x0010` A, `0x0020` B, `0x0040` X,
  `0x0080` Y, `0x0100`/`0x0200`/`0x0400`/`0x0800` D-pad up/down/left/right, `0x1000` LB,
  `0x2000` RB, `0x4000` left stick click, `0x8000` right stick click. `0x0001` is unused.
- Physicality (u32), set while engaged: D-pad up/down/left/right `0x1`/`0x2`/`0x4`/`0x8`, Menu
  `0x10`, View `0x20`, left/right stick click `0x40`/`0x80`, LB/RB `0x100`/`0x200`, Nexus `0x400`,
  A/B/X/Y `0x1000`/`0x2000`/`0x4000`/`0x8000`, left/right trigger `0x10000`/`0x20000`, left stick
  X/Y `0x40000`/`0x80000`, right stick X/Y `0x100000`/`0x200000` (each axis when non-zero).
- Slot 0 merges the player-one controller, the keyboard and the touch controls. The physical field
  holds what the controller and keyboard engage, the virtual field what touch engages; a control
  engaged by both sets its flag in both. With touch neutral, the record is exactly the
  controller's.

Sending:

- Send as soon as anything changes, otherwise every 8 ms; skip a round while 4096 bytes or more
  are queued on `input`. A slot's record goes out when its state changed, or every 50 ms
  unchanged. A press released before the next sample is still sent once (latched).
- Announce a new slot with `gamepadChanged {n, true}` before its first record. A removed slot
  other than 0 gets one neutral record and `gamepadChanged {n, false}`.
- The Guide button is a 120 ms Nexus press on slot 0.

## Rumble

Server packets on `input` have no sequence or timestamp: sections start at offset 2, in the order
ServerMetadata, Vibration.

| Section | Layout (offset in a single-section packet) |
|---|---|
| ServerMetadata (16) | 2 u32 video height, 6 u32 video width |
| Vibration (128), 13 bytes | 2 u8 rumble type (0 four-motor); 3 u8 slot; 4 u8 left motor %; 5 u8 right motor %; 6 u8 left trigger %; 7 u8 right trigger %; 8 u16 duration ms; 10 u16 delay ms; 12 u8 repeat |

- With both sections, vibration starts at offset 10. Percentages are clamped to 100 and mapped to
  0…1. Left is the strong low-frequency motor, right the weak high-frequency one.
- Playback: one CoreHaptics engine per `GCHapticsLocality` (`leftHandle`, `rightHandle`,
  `leftTrigger`, `rightTrigger`), or one `.default` engine at `max(left, right)`. Play
  `repeat + 1` continuous events of `duration`, spaced `duration + delay`. Sharpness is 0.8 on the
  right handle, 0.3 elsewhere. A new effect replaces the playing one.
- An effect plays on the controllers in its slot. Else, for slot 0 with no controller connected
  and device rumble on, it plays on the device's own haptics (one `.default` engine, only where
  `CHHapticEngine.capabilitiesForHardware().supportsHaptics`); else nowhere. Connecting a
  controller stops device rumble. Rumble plays only while its preference is on, and stops when the
  stream ends.

## Touch (iPhone, iPad)

Read from the xbox.com/play web client and Microsoft's Touch Adaptation Kit (TAK) schemas and
samples in `microsoft/xbox-game-streaming-tools` (MIT); recheck against the live services before
relying on a value. Touch is on when the app passes `StreamOptions.touchCapabilities`
(`maxTouchPoints`, `maxLayoutVersion`, `maxManifestVersion`); without it every platform keeps the
start-up values in [Data channels](#data-channels).

| What | Where |
|---|---|
| Does the title have touch? | `POST /v2/titles/inputconfigs` `{titleIds, titleIdType}` (`titleIdType` `xboxTitleId`, after `/streaming/properties/titleinfo` names the running title). Each entry has `supportedTabs` (`[{id}]`) and `supportedInputTypes` (`Controller`, `MKB`, `CustomTouchOverlay`, `GenericTouch`, `NativeTouch`, `NativeSensor`). Cloud titles carry the same two fields. A non-empty `supportedTabs` means a title layout. |
| Its layout bundle | `GET /v1/sessions/tabs/<tabId>/download?noRedirect=true` with the gssv token returns a URL as plain text. A plain `GET` of that URL, without the token, returns a zip: `takxmanifest.json`, `layouts/<locale>/*.json` (falling back to `neutral`), `assets/<locale>/@Nx/*.png`, optional `context.json`. The URL's host is unconfirmed. |
| Turning touch on | Session config `inputConfiguration.enableTouchInput` and `maxTouchPoints`; `touchinputenabledchanged {"touchInputEnabled": true}`; `clientdevicecapabilities {"maxTouchBundleLayoutVersion": "4.1.0.0", "maxTouchBundleManifestVersion": "2.0.0.0"}`; `/streaming/characteristics/touchBundleMetadataChanged {version, versionName}` for the loaded bundle. |

When `titleinfo` names a focused title, ask for its bundle, send `touchBundleMetadataChanged` once
it is loaded, and resolve the layout again after each `patchstate`.

| Incoming on `message`, `/streaming/touchcontrols/…` | Means | `TouchControlsCommand` |
|---|---|---|
| `showlayoutv2` `{layoutId, patch?}` | Show that layout; `layoutId` "" is the standard layout | `.showLayout(.standard` or `.named(id), statePatch:)`; a missing `layoutId` is "" |
| `showlayout` (raw id) | Older form of the above | `.showLayout(…, statePatch: nil)`; the id is the raw content, a JSON string's value, or a `layoutId` field |
| `showtitledefault` | Show the title's default layout | `.showLayout(.titleDefault, statePatch: nil)` |
| `patchstate` `{patch}` | JSON Patch on the layout's `context.json` state | `.patchState(_:)`; a bare JSON array as content is taken as the patch; without one, ignored |
| `hide` | Hide the touch layout | `.hide` |

- A patch is carried as JSON bytes: a string patch as its UTF-8, an array or object
  re-serialized. A transaction on this scope is still answered with `ReceiverCancel`, and its
  command is still reported. The `titleinfo` and `showlayout` payload shapes are unconfirmed, so
  they are decoded defensively as above.
- Layout controls (`button`, `joystick`, `directionalPad`, `throttle`, `touchpad`,
  `arcadeButtons`, wheels, `layer` actions, `turbo`) produce a virtual gamepad: ordinary Gamepad
  records on `input`, with virtual physicality. On iPhone and iPad they become Apple Touch
  Controller controls, whose `GCController` takes no slot of its own and merges into slot 0.
- A controller becomes the active input after a deliberate control (any button, or a stick or
  trigger at 0.3 or more) from it or the keyboard.
- Not sent: relative mouse (a layout may emit it) and Pointer reports (report type 4, which a
  `NativeTouch` title takes). Both need their encodings pinned down here first.
- The standard layout matches the MIT sample `standard-controller.json`: left joystick in
  `left.inner`; D-pad, left stick click, LT and LB in `left.outer`; Y, B, A, X in `right.inner`;
  RB, RT, right stick click and right joystick in `right.outer`; Menu and View at `upper.right`.

## Ending a session

- Keepalive: once streaming, `POST keepalive` with `{}` every keepalive interval. A body
  containing `SessionNotFound` or `SessionNotActive` ends with `.hostEnded`; other failures are
  ignored.
- Stopping sends `gamepadChanged {n, false}` for every announced slot, closes the channels and the
  peer, then sends `DELETE <session URL>`, ignoring the result (safe to repeat).

| Trigger | `StreamEndReason` |
|---|---|
| The user stops, or the start task is cancelled | `.userStopped` |
| iPhone and iPad: the app stayed in the background until its time ran out | `.leftApp` |
| `serverInitiatedDisconnect`, or keepalive `SessionNotFound` / `SessionNotActive` | `.hostEnded` |
| The peer reports `failed` while streaming | `.connectionLost` |
| Any error before streaming | `.failed(<description>)` |

The description is `<code>: <message>` for `GSSVSessionError.failed`, `Timed out waiting for
<resource>` for a timeout, and `HTTP <status> <body code>` (or `HTTP <status>`) for an
`XboxHTTPError`.

## Errors

`StreamFailureAdvice(hostMessage:)` turns a failure description into advice (wording in
[product.md](product.md)). The first match wins; anything unmatched is shown verbatim.

| Host error | Meaning | Advice |
|---|---|---|
| `Failed`, `WNSError` with `WaitingForServerToRegister` | Console not connected to Xbox servers (updating, signed out, needs a power cycle) | Console not registered |
| Message contains `disabled streaming` (any case) | Remote features off | Streaming disabled |
| `ServerStartStreaming…` with `NotFound` | Started again right after the last stream ended | Start not found right after a stream |
| `Timed out waiting for state` | Console not ready within 90 s | Timed out waiting for the console |
| HTTP 409 `DuplicateSessionRequest` | A second `/play` for the same user and title while the first provisions | Duplicate session |
| HTTP 400 on `/play` | No Game Pass or ownership for a cloud title | HTTP 400 when starting |
| `XboxAccountError.signInRequired` | Refresh token rejected | Sign-in no longer valid; the app also asks to sign in again |
| `XboxAccountError.cloudGamingUnavailable` | Neither cloud offering available | The library shows cloud gaming as unavailable |
| `CommandRejected` or no xccs reply | Power command did not reach the console | The library reports a power problem |
| Message contains `xboxstreaminghelper.cpp` | Console streaming service broken; power-cycle it | Shown verbatim |
