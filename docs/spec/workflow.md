# Workflow

The Xcode project is committed and edited in Xcode; its folders are synchronized, so files are
added, moved and deleted in the file system.

## Commands

- Open `Starfold.xcodeproj` and run the `StarfoldMac`, `StarfoldVision` or `StarfoldTV` scheme.
  No signing team is set: choose your own team to run on a device.
- `scripts/format.sh` after editing Swift; `scripts/format.sh --lint` must succeed.
- `scripts/build.sh` builds all three apps; `scripts/build.sh <Scheme>` builds one.
- `scripts/test.sh` runs every package's tests on macOS; `scripts/test.sh <Name>` runs one
  (`StarfoldShared`, `XboxKit`, `StreamKit`). `TV_DESTINATION` adds the Apple TV app's own tests.
- DerivedData never goes inside the repository; set `XCODE_BUILD_ROOT` to move it.

## Adding a feature

1. **Spec first.** Describe the feature in [product.md](product.md), say on which platforms it
   exists, add protocol facts to [streaming.md](streaming.md), and add any rule it needs that is
   missing.
2. **Packages.** Requests and responses go in XboxKit, anything on the live stream in StreamKit,
   each with tests. A package API takes plain values; it never reads `Preferences` or shows text.
3. **ViewModel.** State and decisions go in the ViewModel that owns them (`AppViewModel`,
   `HomeViewModel`, `LibraryViewModel`, `StreamViewModel`, or a new one at the top of its
   `StarfoldShared/Features/<Feature>/` folder), with tests in
   `StarfoldSharedTests/Features/<Feature>/` before the views. A new service, or a value a
   service exchanges, goes in StarfoldShared's `Services/` or `Model/` with its tests.
4. **Platform views.** Each platform that shows the feature gets its own views in
   `Starfold<Platform>/Features/<Feature>/`, the same path as the ViewModel's in StarfoldShared,
   following that platform's conventions; a difference in behaviour is passed into the
   ViewModel, never decided there by `#if os(…)`.
5. **Strings.** Each string gets a semantic key (`<area>.<component>.<element>`) in the catalog
   of the code that shows it: the app target's own `Resources/Localizable.xcstrings` for its
   views, `Packages/StarfoldShared/Sources/StarfoldShared/Resources/` with `bundle: .module` for
   StarfoldShared. Add English, Simplified Chinese and a comment, build, and check that the
   build added no key on its own ([localization.md](localization.md)).
6. **Preview data.** Previews get their data and ViewModels from `PreviewObjectPool`.

## Definition of done

- [ ] Builds without warnings for macOS, visionOS and tvOS in Swift 6 language mode.
- [ ] `scripts/format.sh --lint` succeeds.
- [ ] `scripts/test.sh` passes; every new source file with logic has its test file.
- [ ] No `#if os(…)` in a platform folder, none in StarfoldShared except for a missing API.
- [ ] No `public` in an app; in StarfoldShared, no `public` that an app or a preview does not
      use.
- [ ] No literal strings, colours or symbol names outside their owners.
- [ ] Every new string exists in English and Simplified Chinese.
- [ ] One preview per view file, covering loading, empty, failure and content where the view has
      them.
- [ ] Checked in the running app on every platform it changes: light and dark where the platform
      has both, Dynamic Type, Reduce Motion, VoiceOver.
- [ ] The spec still describes the code.

## Git

- Commit messages are imperative and say what changed and why: `Pin cloud streams to 1080p
  without Game Pass Ultimate`.
- Commit `Starfold.xcodeproj` with its shared schemes and its `Package.resolved`; never commit
  `xcuserdata`, `DerivedData`, `.build` or a package's own `Package.resolved`.
- No large binaries in Git: test media, recordings and screenshots stay outside the repository.
