# ViewModels

A ViewModel holds a screen's state and every decision; the View only shows it. ViewModels are
shared by all platforms, one per feature, in `StarfoldShared/Features/<Feature>/`.

## Ownership

- `AppViewModel` lives for the app, in the environment. It creates the per-account ViewModels,
  the per-stream one and each `SignInViewModel`, and replaces them when the account or stream
  changes.
- Views never create ViewModels; `Navigation/` hands them one. Every page has one, including pages
  reached from another (`makeGameDetailViewModel(for:)`).
- `AppDependencies` is the composition root: it builds the live services once.

## Dependencies

- Everything a ViewModel uses comes through its initializer, stored as `private let`; no default
  arguments for services or data.
- The outside world is reached only through service protocols in `Services/`, each with a `Live…`
  implementation. Live services hold protocol quirks; ViewModels hold state.
- A ViewModel that needs the app sees a narrow protocol `AppViewModel` conforms to (`SigningIn`,
  `SessionControlling`).
- Platform differences arrive as values (`StreamPlatform`, `PictureCapabilities`).
- `XboxAccountError.signInRequired` becomes `onSignInRequired`.
- A ViewModel applies settings itself when `Preferences` changes; screens never forward them.

## Shape

- `@Observable public final class <Feature>ViewModel`, with the feature's `Model/` and
  `Presentation/` beside it.
- `public` for what the apps and previews use, `internal` for its tests, the rest `private`.
- Never imports SwiftUI or a platform UI framework, never reads the environment, no `#if`.
- State is `private(set)`; a writable `var` only for what a View binds to.
- What something is doing is one enum (`LoadState`), not several Booleans and optionals.
- Lists a View shows are computed, never a second stored copy.
- `@ObservationIgnored` only where the compiler needs it or a value must not refresh Views (reason
  in [decisions.md](decisions.md)).

## Intents and queries

- Each thing the person does is one method named for it (`play(_:)`, `togglePower(of:)`): guard
  the precondition, change state, start work.
- An action that needs the app is still the page's intent, calling a closure `AppViewModel` sets
  (`onPlay`, `onRefreshAccount`).
- A question about one element is a method (`cover(for:)`); about the whole, a property
  (`isStreaming`).

## Async work

- Work a screen owns is an `async` method the View calls from `.task`, so SwiftUI cancels it.
- Work that outlives a View is a `Task` the ViewModel stores and cancels.
- Parallel loads use `async let`. After each `await`, a cancelled load changes nothing.
- Old content stays during a refresh; the saved snapshot shows until the first one finishes.

## Previews

Preview services answer at once (`loaded`), never (`loading`) or fail (`failed`), so the View's
own `.task` drives the preview ([testing.md](testing.md#previews)). A stream preview never shows a
first frame.
