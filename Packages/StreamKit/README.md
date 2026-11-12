# StreamKit

Plays one Xbox stream: from the moment a session has an SDP answer until it ends.

**Responsibility:** connect to the host over WebRTC, speak its data-channel protocol, send the
player's input, play rumble, and put the picture on screen at the right time. It knows nothing
about the apps: no strings, no views, no settings — what it needs arrives through
`StreamOptions` and its initializers.

| Folder | Contains |
|---|---|
| `Session/` | `StreamController`, the actor that runs a stream, and the values it reports (`StreamPhase`, `StreamUpdate`, `StreamEndReason`); `HostChannels`, the data-channel conversation as pure values |
| `Connection/` | `StreamRuntime` (the WebRTC factory and audio device every stream shares), the peer connection, ICE candidate gathering, the H.264 decoder factory |
| `Protocol/` | The bytes on the data channels: input reports, control and message channel messages, SDP munging |
| `Input/` | Game controllers (`ControllerHub`), the keyboard as a controller, Apple TV input routing, rumble, the input sender |
| `Audio/` | Stereo audio devices for Mac and for Vision Pro and Apple TV |
| `Rendering/` | Frame queue (`StreamRenderer`), Metal enhancement (`FrameEnhancer`: MetalFX upscaling, sharpening, HDR tone mapping), frame pacing, the system video layer |
| `Quality/` | The quality a person picks and the quality the stream adapts to |
| `Statistics/` | WebRTC statistics turned into `StreamStatistics`, network diagnostics, the copyable report |
| `Logging/` | Log categories |

```swift
let controller = StreamController(
    client: client,
    target: .console(id: console.id, name: console.name),
    options: StreamOptions(clientAppInstallID: installID),
    transferToken: { try await account.transferToken() }
)
Task { for await update in controller.updates { apply(update) } }
await controller.start(sink: renderer, runtime: runtime)
```

Open `Package.swift` in Xcode to build and test it on its own, or run `scripts/test.sh StreamKit`
from the repository root; the tests run on macOS without a host.

The protocol is described in [docs/spec/streaming.md](../../docs/spec/streaming.md).
