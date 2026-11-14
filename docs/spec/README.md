# Starfold Spec

How code in this repository is written. Written for people and for AI agents alike: short, plain
rules with one example where it helps.

- The spec wins: when code and spec disagree, fix the code or change the spec in the same change.
- *Must* and *never* block a review; *prefer* allows a clearer exception.
- Code samples are binding.
- The spec holds rules and their reasons, not lists of what exists; the code says what exists.
  Every change removes what it makes stale, so the spec shrinks as often as it grows.

| File | Answers |
|---|---|
| [product.md](product.md) | What the app does on each platform |
| [architecture.md](architecture.md) | Modules, imports, isolation, where files go |
| [swift-style.md](swift-style.md) | Layout, naming, order, access, control flow |
| [view-models.md](view-models.md) | How ViewModels are owned, fed and shaped |
| [views.md](views.md) | How screens are built and what a View may decide |
| [user-interface.md](user-interface.md) | Palettes, colours, sizes, motion, accessibility |
| [streaming.md](streaming.md) | The Xbox sign-in, session and streaming protocol |
| [decisions.md](decisions.md) | Why the code is the way it is |
| [localization.md](localization.md) | Languages, String Catalogs, formatting |
| [testing.md](testing.md) | Tests, doubles, previews |
| [workflow.md](workflow.md) | Commands, adding a feature, done |
