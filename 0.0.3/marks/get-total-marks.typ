/**
 * Returns the total number of marks accumulated across the document.
 *
 * Reads the final value of the `total-marks` state, which is updated
 * each time `marks` is called. Must be called inside a `context` block.
 */
#let get-total-marks = () => {
  let total-marks-state = state("total-marks", 0)
  return total-marks-state.final()
}
