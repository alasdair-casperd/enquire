#import "_directive.typ": _directive
#import "_eq-state.typ": _eq-state

/// Reset enum numbering so that the next top-level item is numbered `to`.
#let reset-numbering(to: 1) = _directive(_eq-state.update(s => {
  s.path = if to == 1 { () } else { (to - 1,) }
  s.epoch += 1
  s
}))
