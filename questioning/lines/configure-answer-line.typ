#import "_answer-line-state.typ": *

///
/// Configures default answer line display settings, stored in state.
///
/// `lengths` is a dictionary of named lengths, merged into the existing ones, so
/// `(short: 2em)` changes only "short" and `(tiny: 1em)` adds a new name.
///
#let configure-answer-line = (
  length: none,
  lengths: none,
  element: none,
  wrapper: none,
  align: none,
  display: none,
  gap: none,
) => {
  if length != none { _answer-line-length.update(length) }
  if lengths != none { _answer-line-lengths.update(current => current + lengths) }
  if element != none { _answer-line-element.update(_ => element) }
  if wrapper != none { _answer-line-wrapper.update(_ => wrapper) }
  if align != none { _answer-line-align.update(align) }
  if display != none { _answer-line-display.update(display) }
  if gap != none { _answer-line-gap.update(gap) }
}
