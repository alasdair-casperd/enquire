#import "_eq-state.typ": _eq-state

/// The rendered label of the current enum item, e.g. for use inside a
/// question's text. Returns nothing outside any item.
#let current-label() = context {
  let s = _eq-state.get()
  if s.path.len() > 0 { _render-label(s.config, s.data, s.path) }
}
