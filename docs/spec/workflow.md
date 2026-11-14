# Workflow

The Xcode project's folders are synchronized: add, move and delete files in the file system.

## Commands

- `scripts/format.sh` after editing Swift; `scripts/format.sh --lint` must pass.
- `scripts/build.sh [Scheme]` builds every app or one.
- `scripts/test.sh [Package]` runs the package tests on macOS.
- DerivedData never goes inside the repository; set `XCODE_BUILD_ROOT` to move it.
- No signing team is set; choose your own to run on a device.

## Adding a feature

1. Spec first: behaviour in [product.md](product.md), protocol facts in
   [streaming.md](streaming.md), any missing rule.
2. Packages: XboxKit for requests, StreamKit for the live stream, with tests.
3. ViewModel in StarfoldShared, tested before the views.
4. Views for each platform that shows it.
5. Strings in both languages with comments.
6. Previews from `PreviewObjectPool`.

## Done means

- Builds without warnings on every platform; lint and tests pass.
- Checked in the running app on every platform it changes: light and dark, Dynamic Type, Reduce
  Motion, VoiceOver.
- The spec still describes the code, and nothing in it is left stale.

## Git

- Commit messages are imperative and say what changed and why.
- Commit the project, shared schemes and `Package.resolved`; never `xcuserdata`, DerivedData or
  `.build`.
- No large binaries; media, recordings and screenshots stay outside the repository.
