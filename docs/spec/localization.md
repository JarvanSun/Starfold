# Localization

English (development language) and Simplified Chinese. Every user-facing string exists in both
before a change is done.

## String Catalogs

| Owner | Catalog | Key use |
|---|---|---|
| A platform's views | `Starfold<Platform>/Resources/Localizable.xcstrings` | No `table:` or `bundle:` (`Text("settings.title")`) |
| StarfoldShared (ViewModels, their `Model/` and `Presentation/`, its interface pieces) | `Resources/Localizable.xcstrings` | `bundle: .module`; `LocalizedStringResource` uses `BundleDescription.module` from `UserInterface/Extensions/BundleDescriptionExtensions.swift` |
| XboxKit, StreamKit, TopShelfKit, the Top Shelf extension | none | They show no text; the Top Shelf titles arrive localized |

- A key belongs to one catalog: a platform view never writes a StarfoldShared key, and the
  reverse.
- Keys are semantic and dotted, `<area>.<component>.<element>`, each segment starting lowercase
  (`stream.advice.consoleOffline`), never the English sentence.
- A key is written once, where it is used. No key enums, no `static` text.
- Every key has a catalog comment saying where the string appears and what it means. Comments
  live in the catalog, not in code.
- Changing what a string means changes its key; changing only wording keeps the key and updates
  both languages.
- Plurals and device variations are defined in the catalog, never with `if count == 1`.
- After building, the catalog has no new sentence keys, no stale key and none needing review: a
  string the build added on its own should have been a key or `Text(verbatim:)`.

## Copy

- Typographic apostrophes and quotes in both languages (`Couldn’t sign in`, `“%@”`).
- On Mac, buttons and menu commands use title case (`Try Again`); labels, messages and
  descriptions use sentence case.
- Chinese uses what the platform's Chinese system apps say, not a word-for-word translation.
- The app's name is never in a string: it is interpolated from `AppInfo().displayName`
  (`"menuBar.quit \(AppInfo().displayName)"`, key `menuBar.quit %@`), or alone
  `Text(verbatim: AppInfo().displayName)`.

## In code

- A string that belongs to no model is keyed in the view:
  `Text("palette.picker.title", bundle: .module)`.
- Text describing a model is a `LocalizedStringResource` from its presentation extension, one key
  per case:

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

- Strings stay lazy until a `Text` renders them. `String(localized:)` only where a value must be
  resolved text: a shared value every platform reads as `String` (`PowerProblem.title`), a
  formatted value a ViewModel hands out (`StatisticsRow.value`), a failure message carried in a
  state (`SignInPhase.failed(_:)`), or a system API taking `String`.
- Never concatenate localized pieces. A sentence with values is one interpolated key:
  `"library.powerProblem.title \(consoleName)"` is the key `library.powerProblem.title %@`
  (`Couldn’t reach %@`, `无法连接%@`).
- `Text(verbatim:)` and plain `String`s only for values that are not language: a gamertag, a game
  or console name, `1080p`, a key cap letter.

## Numbers and dates

- Durations, bitrates, frame rates and percentages use `FormatStyle`s
  (`.number.precision(.fractionLength(1))`, `.percent`); dates use `Date.FormatStyle`. Never
  hand-built strings or fixed patterns.
- Formatting happens in a presentation extension or a `FormatStyle`, never in a `body`.

## Testing

`LocalizationCatalogTests` (`StarfoldSharedTests`) finds every `.xcstrings` in the repository from
`#filePath`, skipping hidden folders and `DerivedData`, and fails when a key lacks English or
Chinese, is stale or needs review, is not semantic, or has no comment. It also checks that
StarfoldShared's bundle ships every catalog language with a non-empty compiled table.
