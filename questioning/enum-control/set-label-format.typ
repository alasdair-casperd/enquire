#import "_eq-state.typ": _eq-state
#import "_directive.typ": *

/// Change the label format function (see `setup`) from this point on.
/// Pass `auto` to restore the default.
#let set-label-format(fn) = _directive(_eq-state.update(s => {
  s.config.label-format = fn
  s
}))
