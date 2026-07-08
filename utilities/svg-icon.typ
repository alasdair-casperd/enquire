///
/// Utility function to display and optionally colourise an svg icon.
///
#let svg-icon = (source, width: 1.2em, fill: none) => {
  let raw = read(source)
  if fill != none {
    raw = raw.replace("currentColor", fill.to-hex())
  }
  raw = bytes(raw)
  return image(raw, width: width)
}
