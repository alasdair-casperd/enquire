#import "_marks-state.typ": *

///
/// Returns the total number of marks accumulated across the document.
///
/// This works by reading the final value of the `total-marks` state, which is updated each time `marks`
/// is called. Must be called inside a `context` block.
///
#let get-total-marks = () => {
  return _marks-total.final()
}
