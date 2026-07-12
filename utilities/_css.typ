///
/// Converts a length to a CSS length string.
///
#let length-to-css(length-value) = {
  let em = length-value.em
  let pt = length-value.abs.pt()
  if em == 0 { str(pt) + "pt" } else if pt == 0 { str(em) + "em" } else {
    "calc(" + str(em) + "em + " + str(pt) + "pt)"
  }
}

///
/// Converts a single grid track size to a CSS grid track string.
///
#let track-to-css(track) = {
  if track == auto { "auto" } else if type(track) == fraction { repr(track) } else if type(track) == ratio {
    repr(track)
  } else if type(track) == relative {
    "calc(" + repr(track.ratio) + " + " + length-to-css(track.length) + ")"
  } else if type(track) == length { length-to-css(track) } else { "auto" }
}

///
/// Converts a grid columns specification to a CSS grid-template-columns string.
///
#let columns-to-css(columns) = {
  if type(columns) == int { "repeat(" + str(columns) + ", auto)" } else if type(columns) == array {
    columns.map(track-to-css).join(" ")
  } else { track-to-css(columns) }
}

///
/// Converts an alignment to an array of CSS style declarations.
///
#let align-to-css(alignment-value) = {
  let styles = ()
  if type(alignment-value) != alignment { return styles }
  if alignment-value.x != none {
    // left, center, right, start and end are all valid CSS text-align values
    styles.push("text-align: " + repr(alignment-value.x))
  }
  if alignment-value.y != none {
    let vertical = (top: "start", horizon: "center", bottom: "end")
    styles.push("align-self: " + vertical.at(repr(alignment-value.y)))
  }
  styles
}

///
/// Converts an alignment to an array of CSS style declarations for
/// positioning the children of a flexbox row.
///
#let align-to-flex-css(alignment-value) = {
  let styles = ()
  if type(alignment-value) != alignment { return styles }
  if alignment-value.x != none {
    let horizontal = (
      left: "flex-start",
      center: "center",
      right: "flex-end",
      start: "flex-start",
      end: "flex-end",
    )
    styles.push("justify-content: " + horizontal.at(repr(alignment-value.x)))
  }
  if alignment-value.y != none {
    let vertical = (top: "flex-start", horizon: "center", bottom: "flex-end")
    styles.push("align-items: " + vertical.at(repr(alignment-value.y)))
  }
  styles
}
