# Streaming Protocol

How a stream reaches a console (xHome) or a cloud machine (xCloud): sign-in, the gssv session
REST API, WebRTC signalling, the four data channels and their payloads. Values here are what the
servers expect; changing one changes this file first.

| Stage | Module | Types |
|---|---|---|
| Sign-in, token chain, storage | XboxKit `Auth/`, `Storage/` | `DeviceCodeFlow`, `MicrosoftIdentity`, `XboxLiveTokenClient`, `XboxAccount`, `AccountStore`, `SecretStoring` |
| HTTP transport | XboxKit `HTTP/` | `HTTPClient`, `XboxHTTPError` |
| Consoles and power commands | XboxKit `Library/` | `GSSVClient.consoles()`, `XboxLiveClient` |
| Session REST API (play, state, SDP, ICE, keepalive, stop) | XboxKit `Streaming/` | `GSSVClient`, `GSSVSession`, `HostICECandidate`, `TeredoAddress` |
| Peer connection, SDP munging | StreamKit `Connection/`, `Protocol/` | `PeerConnection`, `SDPMunger`, `XboxVideoDecoderFactory` |
| Data channels, input, rumble parsing | StreamKit `Protocol/`, `Input/` | `MessageChannel`, `ControlMessage`, `InputReport`, `ServerInputPacket`, `InputState`, `InputSender` |
| Data-channel conversation (handshake, dialogs, host input events) | StreamKit `Session/` | `HostChannels`, `HostChannelAction` |
| Orchestration and teardown | StreamKit `Session/` | `StreamController` |
| Rumble playback | StreamKit `Input/` | `ControllerHub`, `RumblePlayer` |
| Failure advice | `StarfoldShared/Features/Stream/Model/` | `StreamFailureAdvice` |

All JSON is sent with `.withoutEscapingSlashes`. Xbox dates carry up to 7 fractional digits; the
decoder trims them to milliseconds. `XboxHTTPError` keeps the response body, because these
services explain most failures only there.

## Sign-in and tokens

Sign-in is the OAuth device-code grant (RFC 8628) against Microsoft consumer accounts. There is no
browser redirect and no signed request.

| Constant | Value |
|---|---|
| Client id (`MicrosoftIdentity.clientID`) | `1f907974-e22b-4810-a9de-d9647380c97e`. The transfer token is only known to work with this client, so there is no own app registration. |
| Scope | `xboxlive.signin openid profile offline_access` |
| Form bodies | `application/x-www-form-urlencoded`, every character outside `A-Z a-z 0-9 - . _ ~` percent-encoded |

| Step | Request | Notes |
|---|---|---|
| Code | `POST https://login.microsoftonline.com/consumers/oauth2/v2.0/devicecode` with `client_id`, `scope`, `response_type=device_code` | Returns `device_code`, `user_code`, `verification_uri`, `expires_in`, `interval`. `verification_uri_complete` is usually absent; the app then opens `<verification_uri>?otc=<user_code>`, which skips code entry. |
| Poll | `POST …/consumers/oauth2/v2.0/token` with `grant_type=urn:ietf:params:oauth:grant-type:device_code`, `client_id`, `device_code` | Every `interval` s (5 if absent) until `expires_in` passes. Errors: `authorization_pending` keep polling; `slow_down` add 5 s; `expired_token` → `DeviceCodeError.expired`; `authorization_declined` / `access_denied` → `.declined`; others → `.server`. |
| Refresh | Same URL, `grant_type=refresh_token`, `refresh_token`, `scope` | Keeps the old refresh token if none is returned. HTTP 400 / 401 → `XboxAccountError.signInRequired`. |
| User token | `POST https://user.auth.xboxlive.com/user/authenticate` | `{"Properties":{"AuthMethod":"RPS","RpsTicket":"d=<msa access token>","SiteName":"user.auth.xboxlive.com"},"RelyingParty":"http://auth.xboxlive.com","TokenType":"JWT"}` |
| XSTS | `POST https://xsts.auth.xboxlive.com/xsts/authorize` | `{"Properties":{"SandboxId":"RETAIL","UserTokens":["<user token>"]},"RelyingParty":"<rp>","TokenType":"JWT"}` |
| Streaming token | `POST https://<offering>.gssv-play-prod.xboxlive.com/v2/login/user` | `{"token":"<gssv XSTS>","offeringId":"<offering>"}` |
| Transfer token | `POST https://login.live.com/oauth20_token.srf` with `client_id`, `grant_type=refresh_token`, `refresh_token`, `scope=service::http://Passport.NET/purpose::PURPOSE_XBOX_CLOUD_CONSOLE_TRANSFER_TOKEN` | The v2 refresh token is accepted by this v1 endpoint. `access_token` of the reply is the transfer token. Fetched per stream, never cached. |

User token and XSTS headers: `x-xbl-contract-version: 1`, `Cache-Control: no-cache`, JSON
`Content-Type` and `Accept`, `Origin: https://www.xbox.com`, `Referer: https://www.xbox.com/`.
The streaming login and transfer token send `Cache-Control: no-store, must-revalidate, no-cache`;
the login also `x-gssv-client: XboxComBrowser`. XSTS replies carry `DisplayClaims.xui[0]`: `uhs`
(user hash), and for the web token `gtg` (gamertag) and `xid` (`<xuid>`).

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
  duration), `market` and `offeringSettings.regions[]` (`name`, `baseUri`, `isDefault`). The
  `isDefault` region is used, else the first.
- A 403 `OfferingAccessDenied` means the account cannot use that offering. Cloud tries `xgpuweb`,
  then `xgpuwebf2p`, remembers the winner in `StoredAccount.cloudOffering` and clears it when it
  fails; both failing throws `XboxAccountError.cloudGamingUnavailable`.
- Every token is reused while more than 60 s remain. `XboxAccount` is an actor, so concurrent
  callers share one refresh of the rotating refresh token.
- `StoredAccount` is JSON in the Keychain under `account.<xuid>`. Only its MSA token is essential;
  the Xbox and streaming tokens are caches. The user token lives in memory only.

## Consoles and power

| Request | Auth | Notes |
|---|---|---|
| `GET <xhome baseUri>/v6/servers/home` | Bearer, `X-MS-Device-Info` | `results[]`: `serverId`, `deviceName`, `consoleType`, `powerState`, `outOfHomeWarning`, `wirelessWarning`. Lists only consoles with remote play enabled. |
| `GET https://xccs.xboxlive.com/lists/devices?queryCurrentDevice=false&includeStorageDevices=true` | Web token, contract 2 | `result[]`: `id`, `name`, `consoleType`, `powerState`. Every console on the account; used when the gssv list is empty, so the user learns why a console is missing. |
| `POST https://xccs.xboxlive.com/commands` | Web token, contract 4, `skillplatform: RemoteManagement` | `{"destination":"Xbox","type":"Power","command":"WakeUp" or "TurnOff","sessionId":"<new uuid>","sourceId":"com.microsoft.smartglass","parameters":[],"linkedXboxId":"<serverId>"}`. 10 s timeout. `status.errorCode` other than `OK` → `XboxLiveClient.CommandRejected`. |

xccs calls also send `x-xbl-client-name: XboxApp`, `x-xbl-client-type: UWA`,
`x-xbl-client-version: 39.39.22001.0`. `OK` is the only prompt confirmation of a power command;
the console lists show the new state about a minute later, so the app does not wait for it.

## Session start

Every gssv call goes through `GSSVClient.send` with `Authorization: Bearer <gsToken>`,
`Accept: application/json`, `X-Gssv-Client: XboxComBrowser`, and `Content-Type: application/json`
when there is a body. On 401 or 403 it drops the cached streaming token, fetches a new one and
retries the request once. Media never depends on the token; only signalling and keepalive do.

`POST <baseUri>/v5/sessions/{home|cloud}/play` with header `X-MS-Device-Info` and body:

```json
{ "clientSessionId": "", "titleId": "<cloud titleId, else empty>", "systemUpdateGroup": "",
  "serverId": "<console serverId, else empty>", "fallbackRegionNames": [],
  "settings": { "nanoVersion": "V3;WebrtcTransport.dll", "enableTextToSpeech": false,
    "highContrast": 0, "locale": "<game language, e.g. en-US>", "useIceConnection": false,
    "timezoneOffsetMinutes": <local offset>, "sdkType": "web", "osName": "<osName>",
    "enableOptionalDataCollection": false } }
```

`X-MS-Device-Info` is fixed apart from `dev.os.name`: `appInfo.env` `clientAppId` `www.xbox.com`,
`clientAppType` `browser`, `clientAppVersion` `29.9.35`, `clientSdkVersion` `10.6.8`,
`httpEnvironment` `prod`; `dev.hw` `Microsoft` / `unknown` / `desktop` / `web`; `dev.os` version
`22631.2715`, platform `desktop`; display 4096×2160 at dpi 1, so the display never caps the
stream; browser `edge` `140.0.3485.66`. The host picks the quality tier from the OS name, which
goes in both `dev.os.name` and `settings.osName`:

| `StreamQuality` | `osName` | Stream | Announced size before the host reports its own |
|---|---|---|---|
| `.standard` | `android` | 720p | 1280×720 |
| `.high` | `windows` | 1080p | 1920×1080 |
| `.highest` | `tizen` | Console: 1080p at a higher bitrate. Cloud: 1440p where the title supports it. | 1920×1080 |

A free-to-play cloud account cannot get 1440p; the app pins such a stream to `.high`. The reply
(200 or 202) carries `sessionPath` (no leading slash). The session URL is
`<baseUri>/<sessionPath>`, or `sessionPath` itself when it starts with `http`. Every endpoint
below is relative to the session URL.

## Provisioning and queue

`GSSVSession.waitUntilProvisioned` polls `GET state`. `StreamController` creates the peer and its
offer while this runs, since the offer does not depend on the host.

| `state` | Action |
|---|---|
| `Provisioning` | Keep polling. |
| `WaitingForResources` | Cloud queue. Once, read `GET <baseUri>/v1/waittime/<titleId>` (`estimatedTotalWaitTimeInSeconds`) and report `StreamPhase.queued(estimatedWait:)`. |
| `ReadyToConnect` | Cloud only. Once, `POST connect` with `{"userToken":"<transfer token>"}`, then keep polling. |
| `Provisioned` | Continue with SDP. |
| `Failed` | Throw `GSSVSessionError.failed(code:message:)` from `errorDetails`. |
| anything else | Keep polling. |

- Poll delay grows with elapsed time: 100 ms for the first 2 s, 250 ms until 10 s, 500 ms until
  30 s, then 1 s. The same schedule applies to the SDP and ICE polls.
- Timeout: 90 s for a console (one that answers at all is ready within seconds, even from sleep),
  15 minutes for cloud. Expiry throws `GSSVSessionError.timedOut("state")`.
- `GET configuration` gives `keepAlivePulseInSeconds`; the keepalive interval is that value
  clamped to 5…30 s, 20 s when absent. It is read in parallel with the SDP exchange.

## SDP and ICE

`PeerConnection` builds the peer in this order: audio transceiver `sendrecv` (a microphone could
be attached later), video `recvonly`, then the four data channels, then the offer.

- Configuration: unified plan, `maxBundle`, RTCP mux required, gather once, link-local networks
  (AWDL) and TCP candidates disabled, DSCP on, fast audio jitter-buffer accelerate on. ICE
  servers: `StreamOptions.stunServers`, by default `stun:stun.l.google.com:19302` and
  `stun:stun1.l.google.com:19302`. The host offers no TURN.
- Video codec preferences: H.264 `profile-level-id` `4d…` (Main), then `42e…` (constrained
  baseline), then `420…` (baseline), other H.264, other codecs, RTX and RED last. The host is
  H.264 only. `XboxVideoDecoderFactory` adds Main `4d001f` to the decoder formats; without a `4d`
  entry in the offer the host answers with constrained baseline, which needs more bits.
- Munging (`SDPMunger`), applied to the offer that is both set locally and sent: the Opus
  `a=fmtp` line loses any `stereo`, `sprop-stereo`, `minptime` and `useinbandfec` and gains
  `stereo=1;minptime=10;useinbandfec=1`; when the user caps bitrate, `b=AS:<Mbps × 1000>` goes
  in the video section after any `i=` and `c=` lines, replacing an existing `b=AS`. The answer is
  applied unmodified.

`POST sdp`, then poll `GET sdp` (30 s timeout):

```json
{ "messageType": "offer", "sdp": "<munged offer>",
  "configuration": {
    "chatConfiguration": { "bytesPerSample": 2, "expectedClipDurationMs": 20,
      "format": { "codec": "opus", "container": "webm" }, "numChannels": 1, "sampleFrequencyHz": 24000 },
    "chat": { "minVersion": 1, "maxVersion": 1 }, "control": { "minVersion": 1, "maxVersion": 3 },
    "input": { "minVersion": 1, "maxVersion": 8 }, "message": { "minVersion": 1, "maxVersion": 1 } } }
```

- Not ready: HTTP 204 or an empty body. Ready: `{"exchangeResponse":"<JSON string>","errorDetails":{…}}`;
  `exchangeResponse` is JSON inside a string (an object is accepted too). A non-null
  `errorDetails.code`, or an inner `status` other than `success`, throws `GSSVSessionError.failed`.
- The inner object has `sdp` (the answer) and the negotiated versions `chat`, `control`, `input`,
  `message` (`ChannelVersions`, 1 when missing). Input stays at most 8: input v9 and the
  `reliableinput` / `unreliableinput` channels are not implemented.

Local candidates are sent once, not trickled. Gathering ends when WebRTC reports `complete`, or
when a server-reflexive (`typ srflx`) candidate exists and none arrived for 300 ms, or after 3 s.

- `POST ice` with `{"messageType":"iceCandidate","candidate":[{"candidate":"candidate:…","sdpMid":"0","sdpMLineIndex":0}]}`,
  then poll `GET ice` (30 s timeout). `exchangeResponse` parses to an array of
  `{candidate, sdpMid, sdpMLineIndex}`; host candidates carry an `a=` prefix and `sdpMLineIndex`
  is a string. Everything is bundled on mid `0`; the console listens on UDP 9002.
- `HostICECandidate(_:).expanded` strips `a=`, drops `end-of-candidates` and any candidate with both
  ` udp ` and `tcptype`. A Teredo address (field 5, `2001:0000:…`) gains two host candidates
  before the original: `candidate:10 1 UDP 1 <ipv4> 9002 typ host` and
  `candidate:11 1 UDP 1 <ipv4> <port> typ host`, where port = group 6 XOR `0xFFFF` and ipv4 =
  groups 7–8 XOR `0xFFFFFFFF`. This lets out-of-home console streams connect without IPv6.
- The peer must reach `connected` within 20 s, else `StreamError.connectionTimedOut`.

## Data channels

The client creates all four in-band (no pre-negotiated ids), ordered and reliable. Everything is
sent as binary; JSON is UTF-8. Incoming messages may be text or binary, and NUL bytes are stripped
before parsing.

| Label | Protocol | Content |
|---|---|---|
| `input` | `1.0` | Binary packets, little-endian (see Input encoding) |
| `control` | `controlV1` | JSON `{"message": <name>, …}` |
| `message` | `messageV1` | JSON envelopes |
| `chat` | `chatV1` | Opened, nothing sent; server messages are only logged |

Start-up order. `HostChannels` decides what to send and returns it as `HostChannelAction`s;
`StreamController` performs them:

1. `message` opens → send `Handshake`. `control` opens → send a keyframe request (one sent before
   the channel opened was dropped). Both media tracks received → another keyframe request.
2. `HandshakeAck` arrives → `authorizationRequest` on control; `ClientMetadata` with
   `maxTouchPoints` 0 on input; the six configuration messages on message;
   `gamepadChanged {0, false}` on control.
3. 500 ms later → `gamepadChanged {0, true}`, then `InputSender` starts with slot 0 announced. The
   host only shows a controller after this pair.

| Control message | Fields |
|---|---|
| `authorizationRequest` | `accessKey: "4BDB3609-C1F1-4195-9B37-FEFF45DA8B8E"` (a constant) |
| `gamepadChanged` | `gamepadIndex` 0…3, `wasAdded`. A slot must be announced before records use it. |
| `videoKeyframeRequested` | `ifrRequested: false`. Sent at start-up and on `StreamController.requestKeyframe()`, never periodically. |

Message envelope: `type`, `id` (a lowercase UUID; replies reuse the id they answer), `target`,
`content` (the payload as a JSON string; a raw object is accepted on receipt) and `cv`
(`<uuid without dashes>.<n>`, n counting up per channel). The handshake is
`{"type":"Handshake","version":"messageV1","id":…,"cv":…}`.

| Configuration message (`type: Message`, in this order) | `content` |
|---|---|
| `/streaming/systemUi/configuration` | `{"version":[0,2,0],"systemUis":[10,19]}` (10 virtual keyboard, 19 message dialog) |
| `/streaming/properties/clientappinstallidchanged` | `{"clientAppInstallId":"<uuid, stable per install>"}` |
| `/streaming/characteristics/orientationchanged` | `{"orientation":0}` |
| `/streaming/characteristics/touchinputenabledchanged` | `{"touchInputEnabled":false}` |
| `/streaming/characteristics/clientdevicecapabilities` | `{}` |
| `/streaming/characteristics/dimensionschanged` | `horizontal`, `vertical`, `preferredWidth`, `preferredHeight` = announced size; `safeAreaLeft`/`Top` 0, `safeAreaRight`/`Bottom` = width/height; `supportsCustomResolution: true` |

| Incoming target (`Message` or `TransactionStart`) | Handling |
|---|---|
| `/streaming/systemUi/messages/ShowMessageDialog` | `TitleText`, `ContentText`, non-empty `CommandLabel1…3`, `DefaultIndex`, `CancelIndex` → `SystemDialogRequest`. Reply `TransactionComplete` with `{"Result": <0-based button index>}`. |
| `/streaming/systemUi/messages/ShowVirtualKeyboard` | `TitleText`, `DescriptionText`, `DefaultText`, `MaxLength`. Reply `TransactionComplete` with `{"Text": …}`, or `ReceiverCancel` when the user cancels. |
| `/streaming/sessionLifetimeManagement/serverInitiatedDisconnect` | Reply `TransactionComplete` with `{}` if it is a transaction, then stop with `.hostEnded`. |
| `/streaming/properties/titleinfo` | Ignored. |
| `/streaming/touchcontrols/*` | `ReceiverCancel` for a transaction, otherwise ignored. |
| anything else | Reply `{"type":"Unhandled","id","target","cv"}`. |

A `SenderCancel` withdraws an open dialog (`StreamUpdate.dialogDismissed`), with no reply.

## Input encoding

Client packets: a 14-byte header, then the present sections in the fixed order Metadata, Gamepad,
each starting with a u8 count (at most 255 records). All integers are little-endian.

| Offset | Size | Field |
|---|---|---|
| 0 | u16 | Report-type flags (`InputReportType`): 1 Metadata, 2 Gamepad, 8 ClientMetadata, 16 ServerMetadata (S→C), 128 Vibration (S→C) |
| 2 | u32 | Sequence: 0 for ClientMetadata, then 1, 2, …; it advances only when a send succeeds |
| 6 | f64 | Timestamp in ms on a monotonic clock: `(CACurrentMediaTime() − stream start) × 1000` |

`ClientMetadata` is exactly 15 bytes: the header with flags 8 and sequence 0, then u8
`maxTouchPoints` (0; touch is not supported). Pointer, mouse and keyboard sections are never
sent: a keyboard plays as a gamepad (`KeyboardGamepad`).

| Record | Size | Layout (relative offset: type field) |
|---|---|---|
| Metadata | 28 | 0 u32 RTP timestamp of the frame; 4 u32 first packet arrival; 8 u32 submitted to decoder; 12 u32 decoded; 16 u32 rendered; 20 u32 packet time; 24 u32 date now |
| Gamepad | 23 | 0 u8 slot; 1 u16 buttons; 3 i16 left X; 5 i16 left Y; 7 i16 right X; 9 i16 right Y; 11 u16 left trigger; 13 u16 right trigger; 15 u32 physical physicality; 19 u32 virtual physicality (0) |

- Frame records are one per decoded frame. All four times are the moment the decoded frame reached
  the app, not a paced display time: the host lowers resolution when reported frame times grow,
  and pacing is not latency it can fix. Packet time and date now are the header timestamp
  truncated to u32. At most 29 records wait between packets; older ones are dropped.
- Sticks: `trunc(clamp(v, −1, 1) × 32767)`, up and right positive. GameController already reports
  up as +Y, so nothing is negated. Triggers: `trunc(clamp(t, 0, 1) × 65535)`.
- Buttons (u16): `0x0002` Nexus, `0x0004` Menu, `0x0008` View, `0x0010` A, `0x0020` B, `0x0040` X,
  `0x0080` Y, `0x0100`/`0x0200`/`0x0400`/`0x0800` D-pad up/down/left/right, `0x1000` LB,
  `0x2000` RB, `0x4000` left stick click, `0x8000` right stick click. `0x0001` is unused.
- Physicality (u32), set while the input is engaged: D-pad up/down/left/right `0x1`/`0x2`/`0x4`/`0x8`,
  Menu `0x10`, View `0x20`, left/right stick click `0x40`/`0x80`, LB/RB `0x100`/`0x200`, Nexus
  `0x400`, A/B/X/Y `0x1000`/`0x2000`/`0x4000`/`0x8000`, left/right trigger `0x10000`/`0x20000`,
  left stick X/Y `0x40000`/`0x80000`, right stick X/Y `0x100000`/`0x200000` (each axis when non-zero).

Sending (`InputState`, `InputSender`):

- `InputSender` runs on its own `userInteractive` thread. It sends as soon as anything changes and
  otherwise wakes every 8 ms. It skips a round while 4096 bytes or more are queued on `input`:
  stale input is worse than dropped input.
- A slot's record is sent when its state changed, or every 50 ms while unchanged, so a held stick
  keeps reaching the host. A press released before the next sample is still sent once (latched).
- A new slot is announced with `gamepadChanged {n, true}` before its first record. A removed slot
  other than 0 gets one neutral record and `gamepadChanged {n, false}`.
- The Guide (`StreamController.pressGuide()`) is a 120 ms Nexus press on slot 0.

## Rumble

Server packets on `input` have no sequence or timestamp: sections start at offset 2, walked in
the order ServerMetadata, then Vibration.

| Section | Layout (offset in a single-section packet) |
|---|---|
| ServerMetadata (16) | 2 u32 video height, 6 u32 video width (height first) |
| Vibration (128), 13 bytes | 2 u8 rumble type (0 four-motor); 3 u8 slot; 4 u8 left motor %; 5 u8 right motor %; 6 u8 left trigger %; 7 u8 right trigger %; 8 u16 duration ms; 10 u16 delay ms; 12 u8 repeat |

- Percentages are clamped to 100 and mapped to 0…1. Left is the strong low-frequency motor, right
  the weak high-frequency one. When a packet has both sections, vibration starts at offset 10.
- `RumblePlayer` plays an effect on the controller in that slot with one CoreHaptics engine per
  `GCHapticsLocality` (`leftHandle`, `rightHandle`, `leftTrigger`, `rightTrigger`), or one
  `.default` engine at `max(left, right)`. It plays `repeat + 1` continuous events of `duration`,
  spaced `duration + delay` apart. Sharpness is 0.8 on the right handle and 0.3 elsewhere. A new
  effect replaces the playing one.
- Rumble plays only while the rumble preference is on, and stops when the stream ends.

## Ending a session

- Keepalive: `POST keepalive` with `{}` every keepalive interval once streaming. A body containing
  `SessionNotFound` or `SessionNotActive` ends the stream with `.hostEnded`; other failures are
  ignored until the next pulse.
- `StreamController.stop(reason:)` sends `gamepadChanged {n, false}` for every announced slot,
  closes the channels and the peer, then `DELETE <session URL>`, whose result is ignored, so it is
  safe to repeat.

| Trigger | `StreamEndReason` |
|---|---|
| The user stops, or the start task is cancelled | `.userStopped` |
| `serverInitiatedDisconnect`, or keepalive `SessionNotFound` / `SessionNotActive` | `.hostEnded` |
| The peer reports `failed` while streaming | `.connectionLost` |
| Any error before streaming | `.failed(<description>)` |

The description is `<code>: <message>` for `GSSVSessionError.failed`, `Timed out waiting for
<resource>` for a timeout, and `HTTP <status> <body code>` for an `XboxHTTPError`. Starting a
target that is already starting or playing only brings its window forward: a second `/play` for
the same user and title while the first is provisioning returns HTTP 409 `DuplicateSessionRequest`.

## Errors and what the user sees

`StreamFailureAdvice.advice(for:)` turns a failure description into advice; the first match wins,
and anything unmatched is shown verbatim.

| Host error | Meaning | The app says |
|---|---|---|
| `Failed`, `WNSError` with `WaitingForServerToRegister` | The console is not connected to Xbox servers: updating, signed out, or needing a power cycle | Your console is offline. Make sure it's on or asleep and signed in. |
| Message contains `disabled streaming` | Remote features are off on the console | Remote play is off. Turn on Remote features on your Xbox. |
| `ServerStartStreaming…` with `NotFound` | A console stream was started again right after the last one ended | Your console is still closing the last stream. Try again in a few seconds. |
| `Timed out waiting for state` | A console never became ready within 90 s | Your console didn't answer. Make sure it's on or asleep, not in Energy-saving mode, then try again. |
| HTTP 409 `DuplicateSessionRequest` | A start for this title is still being set up | This game is still starting from your last try. Wait a moment, then try again. |
| HTTP 400 on `/play` | Not permitted: no Game Pass or ownership for a cloud title | This game needs Xbox Game Pass. |
| `XboxAccountError.signInRequired` | The refresh token was rejected | Your sign-in expired. Sign in again to keep playing. (The app also asks to sign in again.) |
| `XboxAccountError.cloudGamingUnavailable` | Neither cloud offering is available to the account | The library shows cloud gaming as unavailable. |
| `CommandRejected` or no reply from xccs | A power command did not reach the console | The library reports a power problem for that console. |
| Message contains `xboxstreaminghelper.cpp` | The console's streaming service is broken; power-cycle it | Shown verbatim. |
