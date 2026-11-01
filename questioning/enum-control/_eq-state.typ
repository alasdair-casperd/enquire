// Core state and numbering machinery.
//
// Everything is driven by a single `state` holding:
// - path:    the current per-level item counts, e.g. (2, 1, 3) = item 2.a.iii
// - epoch:   bumped whenever numbering is reset, so that answer keys stay
//            unique across `reset-numbering` / `prefix` calls
// - data:    user-defined enum data (the "prefix" key is conventional),
//            made available to label customisation
// - answers: recorded answers, keyed by "<epoch>:<path>" so that repeated
//            layout passes (e.g. touying subslides) overwrite rather than
//            duplicate
// - mark-scheme: recorded mark scheme notes, keyed like answers
// - total-items: running count of top-level items while `counted` is true.
//            Unlike `path`, this is not cleared by `reset-numbering` / `prefix`
// - counted: whether new top-level items add to `total-items` (switched off
//            by `end-of-questions`)
// - config:  label customisation and answer display options
//
// The numbering function installed by `setup` both advances `path` and
// renders the label, so enum numbering is fully state-driven: it resumes
// automatically across broken enums, and deeper levels reset whenever a
// parent item advances (the path is truncated to the item's level).

// Exported as `enum-state` for touying decks, which must freeze it so that
// repeated subslide layouts do not advance the numbering:
//   #show: my-theme.with(config-common(frozen-states: (enum-state,)))
#let _eq-state = state("enquire-enum", (
  path: (),
  epoch: 0,
  total-items: 0,
  counted: true,
  data: (:),
  answers: (:),
  mark-scheme: (:),
  config: (
    numbering: ("1.", "a.", "i.", "A.", "I."),
    label-format: auto,
    label-style: auto,
    inline-answers: none,
  ),
))
