#import "../lines/lines.typ": lines as lines-function

/**
 * Displays a right-aligned mark indicator for a question.
 *
 * Parameters:
 * - n (int): The number of marks for the question. Automatically
 *     pluralizes "mark" / "marks" based on the value.
 * - lines (int, auto): Answer lines to display beneath the indicator.
 *     - `0`    — no lines (default).
 *     - `int`  — exactly that many lines.
 *     - `auto` — fills the remainder of the page with lines.
 *
 * Side effect: updates the document-wide `total-marks` state so the
 * running total can be retrieved with `get-total-marks`.
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
