#import "@preview/itemize:0.2.0" as el
#import "prefix.typ": prefix
#import "reset-numbering.typ": reset-numbering as reset

#let simple-enum = (body, reset-numbering: true) => {
  set enum(numbering: "1ai")
  show: prefix[]

  if reset-numbering { reset() }
  body
}

