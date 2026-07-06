#import "/features/questioning/_default-inline-formatter.typ": _default-inline-formatter
#import "/features/questioning/_directive.typ": _directive
#import "/features/questioning/_eq-state.typ": _eq-state
#import "/features/questioning/_normalise-inline.typ": _normalise-inline
#import "/features/questioning/_render-label.typ": _render-label

/// Stable key for the current item. Including the epoch keeps keys unique
/// across `reset-numbering` / `prefix` calls; keying at all means repeated
/// layout (e.g. touying subslides re-laying-out uncovered content) simply
/// overwrites the same entry instead of duplicating it.
#let _answer-key(s) = str(s.epoch) + ":" + s.path.map(str).join(".")
