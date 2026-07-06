#import "_eq-state.typ": _eq-state

/// The info dictionary (see `setup`) for the current enum item. Must be
/// called inside a `context` block; returns `none` outside any item.
#let enum-info() = {
  let s = _eq-state.get()
  if s.path.len() == 0 { none } else { _label-info(s.data, s.path) }
}
