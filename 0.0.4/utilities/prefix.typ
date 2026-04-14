#import "@preview/numbly:0.1.0": numbly
#import "to-string.typ": to-string
#import "reset-numbering.typ": reset-numbering as reset

/**
 * Function to add a prefix before all top-level questions.
 * TODO: Auto continue the same prefix
 */
#let prefix(p, reset-numbering: true) = body => {
  if reset-numbering { reset() }

  let prefix-string = ""

  if not p == none {
    prefix-string = to-string(p)
  }

  set enum(
    full: true,
    numbering: numbly(prefix-string + "{1:1}", "{2:a}", "{3:i}"),
  )

  body
}
