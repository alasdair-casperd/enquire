#import "_lines-state.typ": *

///
/// Configures default line display settings, stored in state.
///
#let configure-lines = (spacing: none, before: none, after: none, element: none, style: none, wrapper: none) => {
  if spacing != none { _lines-spacing.update(spacing) }
  if before != none { _lines-before.update(before) }
  if after != none { _lines-after.update(after) }
  if element != none { _lines-element.update(_ => element) }
  if style != none { _lines-style.update(style) }
  if wrapper != none { _lines-wrapper.update(_ => wrapper) }
}

#let print-lines = (n, spacing, before, after, element, style, wrapper, prompt) => {
  v(before)

  wrapper[

    #v(spacing)

    #for i in range(1, n + 1) {
      if i == 1 and prompt != none {
        prompt
        h(1em)
        let size = measure(prompt)
        box(element.with(..style + (length: 100% - measure(prompt).width - 1em))())
      } else {
        box(element.with(..style)())
      }
      v(spacing)
    }
  ]

  v(after)
}
