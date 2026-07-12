#import "_lines-state.typ": *

///
/// Internal function to display repeated lines, used by the `lines` function.
///
#let _print-lines = (n, spacing, before, after, element, style, wrapper, prompt) => {
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
