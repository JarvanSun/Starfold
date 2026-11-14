# XboxKit

Talks to Microsoft and Xbox Live, so the rest of Starfold never sees a URL, a token or a JSON
shape.

**Responsibility:** sign a person in, keep their tokens fresh, and answer what an app needs to
know: who they are, which consoles they have, which cloud games they can play, how to start a
streaming session, and which touch layout a game brings. It knows nothing about the apps: no strings, no views, no settings.

| Folder | Contains |
|---|---|
| `Auth/` | Device-code sign-in (`DeviceCodeFlow`), the token chain from Microsoft account to Xbox Live to streaming (`XboxLiveTokenClient`), signed-in accounts (`XboxAccount`, `AccountStore`) |
| `HTTP/` | `HTTPClient`, `XboxHTTPError`, Xbox's date format |
| `Library/` | Profile, consoles and their power commands (`XboxLiveClient`), cloud titles, the store catalogue (`CatalogClient`) |
| `Storage/` | Where tokens are kept: the Keychain (`KeychainStore`) or memory (`InMemorySecretStore`) |
| `Streaming/` | The streaming session REST API (`GSSVClient`, `GSSVSession`): start, provisioning, SDP and ICE exchange, keep-alive |
| `Touch/` | Which titles have their own touch layout (`TitleInputConfiguration`), downloading and unzipping a title's layout bundle (`TouchBundle`), its layouts as values (`TouchLayout`), and the game's state patches (`TouchContext`, `JSONPatch`) |

```swift
let store = AccountStore(
    microsoftClientID: "<your client ID>",
    secrets: KeychainStore(service: "com.example.starfold.accounts")
)
let prompt = try await store.beginSignIn()
let account = try await store.completeSignIn(prompt)
let consoles = try await account.homeClient(http: HTTPClient()).consoles()
```

Open `Package.swift` in Xcode to build and test it on its own, or run `scripts/test.sh XboxKit`
from the repository root; the tests run on macOS without network.

The protocol it speaks is described in [docs/spec/streaming.md](../../docs/spec/streaming.md).
