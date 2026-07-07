#import "_directive.typ": _directive
#import "_eq-state.typ": _eq-state

/// Set (or with `value: none`, remove) a custom enum data entry. The full
/// data dictionary is passed to label-format / label-style and is stored
/// alongside recorded answers.
///
/// ```typst
/// #set-enum-data("color", red)
/// ```
#let set-enum-data(key, value) = _directive(_eq-state.update(s => {
  if value == none {
    let _ = s.data.remove(key, default: none)
  } else {
    s.data.insert(key, value)
  }
  s
}))
