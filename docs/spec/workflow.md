# Workflow

The Xcode project is committed and its folders are synchronized: add, move and delete files in
the file system.

## Commands

- Open `Starfold.xcodeproj` and run the `StarfoldMac`, `StarfoldVision` or `StarfoldTV` scheme.
  No signing team is set; choose your own to run on a device.
- `scripts/format.sh` after editing Swift; `scripts/format.sh --lint` must succeed.
- `scripts/build.sh` builds every app; `scripts/build.sh <Scheme>` builds one.
- `scripts/test.sh` runs every package's tests on macOS; `scripts/test.sh <Name>` runs one
  (`StarfoldShared`, `XboxKit`, `StreamKit`).
- DerivedData never goes inside the repository; set `XCODE_BUILD_ROOT` to move it.

## Adding a feature

1. **Spec first:** the feature and its platforms in [product.md](product.md), protocol facts in
   [streaming.md](streaming.md), any missing rule.
2. **Packages:** requests and responses in XboxKit, anything on the live stream in StreamKit, with
   tests. A package API takes plain values.
3. **ViewModel:** state and decisions in the ViewModel that owns them, or a new one in
   `StarfoldShared/Features/<Feature>/`, tested before the views. A new service or exchanged value
   goes in `Services/` or `Model/` with tests.
4. **Platform views** in `Starfold<Platform>/Features/<Feature>/` for each platform that shows it.
5. **Strings** in the catalog of the code that shows them, English, Chinese and a comment
   ([localization.md](localization.md)).
6. **Previews** from `PreviewObjectPool`.

## Definition of done

- [ ] Builds without warnings for macOS, visionOS and tvOS.
- [ ] `scripts/format.sh --lint` succeeds and `scripts/test.sh` passes.
- [ ] Checked in the running app on every platform it changes: light and dark where the platform
      has both, Dynamic Type, Reduce Motion, VoiceOver.
- [ ] The spec still describes the code.

## Git

- Commit messages are imperative and say what changed and why.
- Commit `Starfold.xcodeproj` with its shared schemes and `Package.resolved`; never `xcuserdata`,
  `DerivedData`, `.build` or a package's own `Package.resolved`.
- No large binaries: test media, recordings and screenshots stay outside the repository.
