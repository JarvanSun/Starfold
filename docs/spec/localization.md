# Localization

English (development language) and Simplified Chinese. Every string people read exists in both
before a change is done.

## Catalogs and keys

- A platform's views use `Starfold<Platform>/Resources/Localizable.xcstrings`
  (`Text("settings.title")`). StarfoldShared uses its own catalog with `bundle: .module`. The other
  packages show no text.
- A key belongs to one catalog and is written once, where it is used. No key enums.
- Keys are dotted and semantic, `<area>.<component>.<element>` (`stream.advice.consoleOffline`),
  never the English sentence.
- Every key has a catalog comment saying where it appears and what it means.
- A new meaning gets a new key; a wording change keeps the key and updates both languages.
- Plurals and device variants are defined in the catalog, never with `if count == 1`.
- After a build the catalog has no sentence keys, stale keys or keys needing review.
  `LocalizationCatalogTests` checks this, plus both languages and a comment on every key.

## Copy

- Typographic apostrophes and quotes (`Couldn’t`, `“%@”`).
- Mac buttons and menu commands use title case (`Try Again`); everything else sentence case.
- Chinese says what the system's Chinese apps say, not a word-for-word translation.
- The app's name is never in a string; interpolate `AppInfo().displayName`.

## In code

- Text about a model comes from its presentation extension as a `LocalizedStringResource`, one
  key per case. Other text is keyed in the view.
- Strings stay lazy until a `Text` shows them. `String(localized:)` only where a resolved `String`
  is needed (a value every platform reads as text, a failure message in a state, a system API).
- A sentence with values is one interpolated key (`"library.powerProblem.title \(consoleName)"` →
  `library.powerProblem.title %@`), never concatenated pieces.
- `Text(verbatim:)` only for values that aren't language: a gamertag, a game name, `1080p`.
- Numbers, durations and dates use `FormatStyle`s, in a presentation extension, never in a `body`.
