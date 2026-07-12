#import "_lines-state.typ": *
#import "_print-lines.typ": _print-lines

///
/// Function to display repeated lines.
///
#let lines = (
  n,
  spacing: none,
  before: none,
  after: none,
  element: none,
  style: none,
  wrapper: none,
  prompt: none,
) => {
  context {
    let effective-spacing = if spacing != none { spacing } else { _lines-spacing.get() }
    let effective-before = if before != none { before } else { _lines-before.get() }
    let effective-after = if after != none { after } else { _lines-after.get() }
    let effective-element = if element != none { element } else { _lines-element.get() }
    let effective-style = if style != none { style } else { _lines-style.get() }
    let effective-wrapper = if wrapper != none { wrapper } else { _lines-wrapper.get() }

    if n == auto {
      block(height: 1fr, width: 100%, clip: true)[
        #repeat(
          _print-lines(
            100,
            effective-spacing,
            effective-before,
            effective-after,
            effective-element,
            effective-style,
            effective-wrapper,
            prompt,
          ),
        )
      ]
      return
    }

    _print-lines(
      n,
      effective-spacing,
      effective-before,
      effective-after,
      effective-element,
      effective-style,
      effective-wrapper,
      prompt,
    )
  }
}
