#import "/features/questioning/_default-inline-formatter.typ": _default-inline-formatter
#import "/features/questioning/_directive.typ": _directive
#import "/features/questioning/_eq-state.typ": _eq-state
#import "/features/questioning/_normalise-inline.typ": _normalise-inline
#import "/features/questioning/_render-label.typ": _render-label

/// Forget all answers recorded so far.
#let clear-answers() = _directive(_eq-state.update(s => {
  s.answers = (:)
  s
}))
