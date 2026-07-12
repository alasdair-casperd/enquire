#import "/questioning/enum-control/_default-inline-formatter.typ": _default-inline-formatter
#import "/questioning/enum-control/_directive.typ": _directive
#import "/questioning/enum-control/_eq-state.typ": _eq-state
#import "/questioning/enum-control/_normalise-inline.typ": _normalise-inline
#import "/questioning/enum-control/_render-label.typ": _render-label

/// Forget all answers recorded so far.
#let clear-answers() = _directive(_eq-state.update(s => {
  s.answers = (:)
  s
}))
