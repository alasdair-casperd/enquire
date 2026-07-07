#import "_eq-state.typ": _eq-state
#import "_render-label.typ": _render-label

/// The enum numbering function. Typst's own numbers are ignored (they reset
/// across broken enums); only their count is used, which gives the nesting
/// level since `setup` sets `enum(full: true)`.
#let _marker(..nums) = {
  let level = nums.pos().len()
  _eq-state.update(s => {
    let path = s.path
    if path.len() < level { path += (0,) * (level - path.len()) }
    path = path.slice(0, level)
    path.at(level - 1) += 1
    s.path = path
    s
  })
  context {
    let s = _eq-state.get()
    _render-label(s.config, s.data, s.path)
  }
}
