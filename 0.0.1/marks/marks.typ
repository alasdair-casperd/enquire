#import "../lines/lines.typ": lines

/**
 * Function to display a number of marks.
 */
#let marks = (n, space: 0) => {
  let word = if (n > 1) { "marks" } else { "mark" }
  v(-0.3em)
  box(width: 100%, align(right)[*[#n #word]*])
  if (space > 0) { v(-0.7em) }
  [#lines(space)]

  let total-marks = state("total-marks", 0)
  total-marks.update(t => t + n)
}
