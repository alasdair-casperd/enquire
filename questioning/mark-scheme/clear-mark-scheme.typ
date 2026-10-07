#import "/questioning/enum-control/_directive.typ": _directive
#import "/questioning/enum-control/_eq-state.typ": _eq-state

/// Forget all mark scheme notes recorded so far.
#let clear-mark-scheme() = _directive(_eq-state.update(s => {
  s.mark-scheme = (:)
  s
}))
