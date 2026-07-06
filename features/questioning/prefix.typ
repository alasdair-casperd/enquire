#import "_directive.typ": _directive
#import "_eq-state.typ": _eq-state

/// Set the numbering prefix for the questions that follow. This is a special
/// case of `set-enum-data`; by default it also resets numbering (a new prefix
/// usually means a new section). Pass `none` or `[]` to remove the prefix.
///
/// ```typst
/// #prefix[A]
/// ...
/// #prefix[]  // remove
/// ```
#let prefix(p, reset: true) = _directive(_eq-state.update(s => {
  let value = if p == none or p == [] { none } else { p }
  if value == none {
    let _ = s.data.remove("prefix", default: none)
  } else {
    s.data.insert("prefix", value)
  }
  if reset {
    s.path = ()
    s.epoch += 1
  }
  s
}))
