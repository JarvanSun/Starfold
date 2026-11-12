# StarfoldShared

What the Mac, Vision Pro and Apple TV apps share: every feature's ViewModel, the services a
ViewModel reaches the outside world through, the storage it saves to, the values those exchange,
and the interface pieces every platform uses.

**Responsibility:** hold the state and decisions of every page, talk to Xbox and the stream,
keep what must be kept, and give every platform the same look. It holds no page: each app's
views of a feature are in `Starfold<Platform>/Features/<Feature>/`, the same path as the
feature's ViewModel here. It never decides by platform.

| Folder | Contains |
|---|---|
| `App/` | `AppViewModel` (who is signed in, the accounts, the current stream), `AppDependencies` (the composition root), `AppInfo`, `SceneID` |
| `Features/` | One folder per page (`SignIn`, `Home`, `Library`, `Settings`, `Stream`): its ViewModel, the values it shows (`Model/`) and their display text (`Presentation/`) |
| `Services/` | The protocols the ViewModels talk through (`AccountService`, `ConsoleService`, `CloudLibraryService`, `StreamService`), their live implementations on XboxKit and StreamKit, and storage (`Preferences`, `FavoritesStore`, `LibraryCache`) |
| `Model/` | The values the services and storage exchange: `AccountSummary`, `CloudLibrary`, `CloudAccess`, `HomeSnapshot`, `LibrarySnapshot`, `GameSort`, `SoundStage`, `LoadState` |
| `Logging/` | `LogCategory` and the `Logger` initializer that takes one |
| `UserInterface/` | What every platform's views use: palettes and colours, the spacing scale (`Dimensions`), button styles, modifiers, small components, the animated sky background |
| `Resources/` | The String Catalog, the privacy manifest |

The package's second target, `TopShelfKit`, is the Apple TV Top Shelf snapshot: what the Apple TV
app writes to the App Group and the Top Shelf extension reads.

```swift
@State private var app = AppDependencies(streamPlatform: StreamPlatform()).makeAppViewModel()

var body: some Scene {
    WindowGroup {
        RootView()
            .environment(app)
            .task { await app.restore() }
    }
}
```

`AppDependencies` builds the live services once and hands them to `AppViewModel`; previews and
tests give the ViewModels preview services and stubs that implement the same protocols.

Open `Package.swift` in Xcode to build, test and preview it on its own, or run
`scripts/test.sh StarfoldShared` from the repository root; the tests run on macOS without
network.
