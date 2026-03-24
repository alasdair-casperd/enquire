#import "../lines/lines.typ": lines as lines-function

/**
 * Function to display a number of marks.
 * N.B. Both 'space' and 'lines' are supported for backwards compatibility.
 * TODO: Remove in a 1.1.4
 */
#let marks = (n, lines: 0) => {
  let word = if (n > 1) { "marks" } else { "mark" }
  v(-0.3em)
  box(width: 100%, align(right)[*[#n #word]*])
  if (type(lines) != int or lines > 0) { v(-0.7em) }
  [#lines-function(lines)]

  let total-marks = state("total-marks", 0)
  total-marks.update(t => t + n)
}
