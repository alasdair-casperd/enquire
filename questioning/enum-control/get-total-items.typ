#import "_eq-state.typ": _eq-state

///
/// Returns the number of top-level enum items counted across the document.
///
/// This works by reading the final value of a running total, which advances
/// each time a top-level item is numbered. The total is unaffected by
/// `reset-numbering` or `prefix`, so a six-question paper returns 6 even if
/// numbering restarts part way through. Items after `end-of-questions` are
/// not counted. Must be called inside a `context` block.
///
#let get-total-items = () => {
  return _eq-state.final().total-items
}
