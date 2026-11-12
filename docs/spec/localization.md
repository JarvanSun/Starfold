# Localization

The app ships in English (development language) and Simplified Chinese. Every user-facing string
exists in both before a change is done.

## String Catalogs

- Each owner of text has its own String Catalog, holding only the strings its code uses:
  - Each platform's views (`StarfoldMac/`, `StarfoldVision/`, `StarfoldTV/`) read their app's
    own `Starfold<Platform>/Resources/Localizable.xcstrings`; their keys take no `table:` or
    `bundle:` argument (`Text("settings.title")`).
  - StarfoldShared reads its `Resources/Localizable.xcstrings` with `bundle: .module`: `Text` and
    `String(localized:)` take SwiftPM's `Bundle.module`, `LocalizedStringResource` the internal
    `LocalizedStringResource.BundleDescription.module` in
    `UserInterface/Extensions/BundleDescriptionExtensions.swift`. It holds the strings of the
    ViewModels, their `Model/` and `Presentation/`
    (`String(localized: "signIn.failure.declined", bundle: .module)`) and of StarfoldShared's own
    interface pieces (the palette names, the clock).
  - A key belongs to one catalog: a platform view never writes a StarfoldShared key, and
    StarfoldShared never one of an app's.
  - XboxKit, StreamKit and TopShelfKit show no text and have no catalog. The Top Shelf extension
    shows titles the Apple TV app wrote already localized.
- Keys are semantic and dotted, `<area>.<component>.<element>`, each segment starting with a
  lowercase letter (`stream.advice.consoleOffline`, `library.powerProblem.title`,
  `palette.nebula.name`), never the English sentence. The English text is the key's `en` value
  in the catalog.
- A key is written once, where it is used. There are no key enums and no `static` text.
- Every key has a catalog comment saying where the string appears and what it means there.
  Comments live in the catalog, not in code.
- Changing what a string means changes its key; changing only its wording keeps the key and
  updates both languages in the same change.
- Plurals and device variations are defined in the catalog, never with `if count == 1`.
- A build syncs the strings it extracts from code into the catalog. After building, the catalog
  has no new sentence keys, no key marked stale and none needing review: a string the build added
  on its own is a literal that should have been a key or `Text(verbatim:)`.

## Copy

- Typographic apostrophes and quotes in both languages (`Couldn’t sign in`, `“%@”`), never
  `'` or `"`.
- On Mac, buttons and menu commands use title case (`Try Again`, `Open Xbox Guide`), as the
  Mac's own apps do; labels, messages and descriptions use sentence case.
- Chinese says what Chinese Mac, Vision Pro and Apple TV system apps say for the same thing on
  that platform, not a word-for-word translation.
- The app's name is never written in a string: it is interpolated from
  `AppInfo().displayName`, which reads `CFBundleDisplayName`, into a key that takes it as an
  argument (`"menuBar.quit \(AppInfo().displayName)"`, the catalog key `menuBar.quit %@`). Alone,
  it is `Text(verbatim: AppInfo().displayName)`.

## In code

- A string that belongs to no model is keyed in the view (here in StarfoldShared, hence
  `bundle: .module`):

  ```swift
  .accessibilityLabel(Text("theme.clock.accessibilityLabel", bundle: .module))

  Picker(selection: $selection) {
      ForEach(palettes, content: option(for:))
  } label: {
      Text("palette.picker.title", bundle: .module)
  }
  ```

- Text that describes a model is a `LocalizedStringResource`, built in the presentation
  extension that owns it, one key per case:

  ```swift
  extension Palette {
      var name: LocalizedStringResource {
          switch id {
          case .nebula: .init("palette.nebula.name", bundle: .module)
          case .aurora: .init("palette.aurora.name", bundle: .module)
          case .sunrise: .init("palette.sunrise.name", bundle: .module)
          }
      }
  }
  ```

- Strings stay lazy until a `Text` renders them. `String(localized:)` only where a value must
  be resolved text: a shared value every platform reads as `String` (`PowerProblem.title`), a
  formatted value a ViewModel hands out (`StatisticsRow.value`, a queue's estimated wait), a
  failure message carried in a state (`SignInPhase.failed(_:)`), or an
  AppKit or system API that takes a `String`.

  ```swift
  extension PowerProblem {
      var title: String {
          String(localized: "library.powerProblem.title \(consoleName)", bundle: .module)
      }
  }
  ```

- Never concatenate localized pieces. A sentence with values is one key with interpolation, so
  the translation can reorder it: `"library.powerProblem.title \(consoleName)"` is the catalog
  key `library.powerProblem.title %@`, with `Couldn’t reach %@` in English and `无法连接%@` in
  Chinese.
- `Text(verbatim:)` and plain `String`s only for values that are not language: a gamertag, a
  game or console name, a resolution (`1080p`), a key cap letter.

## Numbers and dates

- Durations, bitrates, frame rates and percentages use `FormatStyle`s
  (`.formatted(.units(allowed: [.milliseconds]))`, `.number.precision(.fractionLength(1))`,
  `.percent`), never hand-built strings.
- Dates use `Date.FormatStyle`, never fixed patterns.
- Formatting happens in a presentation extension or a `FormatStyle`, never in a `body`.

## Testing

`LocalizationCatalogTests` in `StarfoldSharedTests` finds every `.xcstrings` in the repository
from `#filePath` (skipping hidden folders and `DerivedData`): the three apps' catalogs and
StarfoldShared's. For each catalog it fails when a key lacks an English or Chinese value, is
stale or needs review, is not a semantic key, or has no comment. It also checks that
StarfoldShared's bundle ships every language in its catalog with a non-empty compiled table.
