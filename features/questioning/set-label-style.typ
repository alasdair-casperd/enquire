#import "_eq-state.typ": _eq-state
#import "_directive.typ": _directive

/// Change the label style function (see `setup`) from this point on.
/// Pass `auto` to restore the default.
#let set-label-style(fn) = _directive(_eq-state.update(s => {
  s.config.label-style = fn
  s
}))
