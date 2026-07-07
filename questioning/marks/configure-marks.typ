///
/// Configures default mark display settings, stored in state.
///
#let configure-marks = (style: none, weight: none, formatter: none, inline: none) => {
  if style != none { _marks-style.update(style) }
  if weight != none { _marks-weight.update(weight) }
  if formatter != none { _marks-formatter.update(_ => formatter) }
  if inline != none { _marks-inline.update(inline) }
}
