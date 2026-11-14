<p align="center">
  <b>English</b> · <a href="README.zh-Hans.md">简体中文</a>
</p>

<h1 align="center">Starfold — Xbox Remote Play and Cloud Gaming for Apple platforms</h1>

<p align="center">
  Stream your own Xbox console or play Xbox Cloud Gaming, in a native SwiftUI app.
</p>

<p align="center">
  <a href="../../releases/latest"><b>Download for Mac</b></a>
  ·
  <a href="#build-from-source"><b>Build from source</b></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-26-black" alt="macOS 26">
  <img src="https://img.shields.io/badge/iOS-26-black" alt="iOS 26">
  <img src="https://img.shields.io/badge/iPadOS-26-black" alt="iPadOS 26">
  <img src="https://img.shields.io/badge/visionOS-26-black" alt="visionOS 26">
  <img src="https://img.shields.io/badge/tvOS-26-black" alt="tvOS 26">
  <img src="https://img.shields.io/badge/Swift-6-F05138" alt="Swift 6">
  <img src="https://img.shields.io/badge/license-MIT-blue" alt="MIT License">
</p>

<p align="center">
  <img src=".github/assets/en/mac-hero.jpg" alt="Starfold on Mac: Remote Play and Cloud Gaming" width="100%">
</p>

## What it does

- **Remote Play**: stream your own Xbox Series X|S or Xbox One.
- **Cloud Gaming**: play Xbox Cloud Gaming without a console.
- **Accounts**: sign in with several Microsoft accounts and switch between them.
- **Library**: Continue Playing, favorites, search and sorting.
- **Platforms**: Mac, iPhone, iPad, Apple Vision Pro and Apple TV, all native.
- **Video**: up to 80 Mbps, low-latency mode; MetalFX upscaling and HDR tone mapping on Mac.
- **Picture in Picture**: keep playing in a floating window on Mac.
- **Input**: game controllers on every platform; keyboard on Mac, iPhone and iPad.
- **Touch controls**: on iPhone and iPad, with Apple's
  [Touch Controller](https://developer.apple.com/documentation/touchcontroller); games' own touch
  layouts are supported, and the standard layout can be customized.

## Mac

<table>
  <tr>
    <td><img src=".github/assets/en/mac-remote-play.jpg" alt="Your console on your Mac"></td>
    <td><img src=".github/assets/en/mac-cloud-gaming.jpg" alt="Cloud Gaming on Mac"></td>
  </tr>
  <tr>
    <td><img src=".github/assets/en/mac-metalfx.jpg" alt="Sharper with MetalFX"></td>
    <td><img src=".github/assets/en/mac-picture-in-picture.jpg" alt="Picture in Picture"></td>
  </tr>
</table>

## iPhone

<table>
  <tr>
    <td width="19.4%"><img src=".github/assets/en/iphone-home.jpg" alt="Home on iPhone"></td>
    <td width="80.6%"><img src=".github/assets/en/iphone-touch.jpg" alt="Touch controls on iPhone"></td>
  </tr>
  <tr>
    <td width="80.6%"><img src=".github/assets/en/iphone-layout.jpg" alt="Customizing the touch layout"></td>
    <td width="19.4%"><img src=".github/assets/en/iphone-cloud.jpg" alt="Cloud Gaming on iPhone"></td>
  </tr>
</table>

## iPad

<table>
  <tr>
    <td><img src=".github/assets/en/ipad-welcome.jpg" alt="Welcome on iPad"></td>
    <td><img src=".github/assets/en/ipad-game.jpg" alt="Game details on iPad"></td>
  </tr>
</table>

## Apple Vision Pro

<table>
  <tr>
    <td><img src=".github/assets/en/vision-giant-screen.jpg" alt="Remote Play on a giant screen"></td>
    <td><img src=".github/assets/en/vision-remote-play.jpg" alt="Your console in your space"></td>
    <td><img src=".github/assets/en/vision-cloud-gaming.jpg" alt="Cloud Gaming on Apple Vision Pro"></td>
  </tr>
</table>

## Apple TV

<table>
  <tr>
    <td><img src=".github/assets/en/tv-remote-play.jpg" alt="Your console on your TV"></td>
    <td><img src=".github/assets/en/tv-cloud-gaming.jpg" alt="Cloud Gaming on Apple TV"></td>
  </tr>
</table>

## Requirements

macOS 26, iOS 26, iPadOS 26, visionOS 26 or tvOS 26 or later.

## Build from source

Requires Xcode 27 or later.

1. Clone the repository and open `Starfold.xcodeproj`.
2. Choose the `StarfoldMac`, `StarfoldiOS`, `StarfoldVision` or `StarfoldTV` scheme.

## Code

Four thin platform apps share one app layer and two protocol packages:

![Modules: four platform apps over StarfoldShared, which uses XboxKit and StreamKit](docs/spec/images/modules.svg)

| Module | Responsibility |
|---|---|
| [`StarfoldShared`](Packages/StarfoldShared) | The ViewModels every platform shares, their services and storage, and the shared interface pieces |
| [`XboxKit`](Packages/XboxKit) | Microsoft and Xbox Live sign-in, tokens, consoles, the cloud catalogue and the streaming session API |
| [`StreamKit`](Packages/StreamKit) | One stream: WebRTC, data channels, controller input, rumble, Metal rendering and frame pacing |

Swift 6 with strict concurrency, MVVM with Observation, Swift Testing, English and Simplified
Chinese. How the code is written — architecture, style, views, testing — is described in
[docs/spec](docs/spec/README.md).

## Acknowledgements

Starfold streams with LiveKit's [webrtc-xcframework](https://github.com/livekit/webrtc-xcframework)
(MIT), built from WebRTC (BSD 3-Clause). Full licence texts are in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

Starfold is released under the [MIT License](LICENSE).

Starfold is an independent app and is not affiliated with, endorsed by, or sponsored by Microsoft
Corporation. Xbox, Xbox Game Pass and Xbox Cloud Gaming are trademarks of Microsoft Corporation,
used for identification only. Game artwork in the screenshots belongs to its publishers.
