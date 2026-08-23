#import "_eq-state.typ": _eq-state

///
/// Returns the number of top-level enum items reached across the document.
///
/// This works by reading the final value of the shared enum-control state,
/// which advances each time a top-level item is numbered. Must be called
/// inside a `context` block.
///
/// Note: `reset-numbering` clears the tracked path, so this returns the
/// count since the last reset rather than a running total across resets.
///
#let get-total-items = () => {
  return _eq-state.final().path.at(0, default: 0)
}
