# Starfold Spec

How code in this repository is written.

- **The spec wins.** When code and spec disagree, the code is wrong, or the spec changes in the
  same change.
- *Must* and *never* block a review; *prefer* allows a deviation when the code is clearer for it.
- Code samples are binding.

| File | Answers |
|---|---|
| [product.md](product.md) | What the app does, and what differs on Mac, Vision Pro, Apple TV, iPhone and iPad |
| [architecture.md](architecture.md) | Which modules and targets exist, what may import what, where a file goes |
| [swift-style.md](swift-style.md) | Formatting, naming, declaration order, access control, control flow |
| [view-models.md](view-models.md) | The ViewModels, the services they use, and their shape |
| [views.md](views.md) | How screens are composed and what a `body` may contain |
| [user-interface.md](user-interface.md) | Palettes, colours, cards, motion, accessibility |
| [streaming.md](streaming.md) | The Xbox sign-in, session and streaming protocol XboxKit and StreamKit implement |
| [decisions.md](decisions.md) | Why the code is the way it is: workarounds, measured timings, deliberate choices |
| [localization.md](localization.md) | English and Simplified Chinese, String Catalogs, formatting |
| [testing.md](testing.md) | Swift Testing, stubs and dummies, previews |
| [workflow.md](workflow.md) | Commands, adding a feature, and the definition of done |
