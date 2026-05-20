
#let _lines-spacing = state("lines-spacing", 1em)
#let _lines-before = state("lines-before", 0em)
#let _lines-after = state("lines-after", 0.3em)
#let _lines-element = state("lines-element", line.with(length: 100%))
#let _lines-style = state("lines-style", (:))
#let _lines-wrapper = state("lines-wrapper", x => x)

/**
 * Configures default line display settings, stored in state.
 */
#let configure-lines = (spacing: none, before: none, after: none, element: none, style: none, wrapper: none) => {
  if spacing != none { _lines-spacing.update(spacing) }
  if before != none { _lines-before.update(before) }
  if after != none { _lines-after.update(after) }
  if element != none { _lines-element.update(_ => element) }
  if style != none { _lines-style.update(style) }
  if wrapper != none { _lines-wrapper.update(_ => wrapper) }
}

#let print-lines = (n, spacing, before, after, element, style, wrapper) => {
  v(before)

  wrapper[

    #v(spacing)

    #for _ in range(1, n + 1) {
      element.with(..style)()
      v(spacing)
    }
  ]


  v(after)
}

/**
 * Function to display repeated lines.
 */
#let lines = (
  n,
  spacing: none,
  before: none,
  after: none,
  element: none,
  style: none,
  wrapper: none,
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
          print-lines(100, effective-spacing, effective-before, effective-after, effective-element, effective-style, effective-wrapper),
        )
      ]
      return
    }

    print-lines(n, effective-spacing, effective-before, effective-after, effective-element, effective-style, effective-wrapper)
  }
}
