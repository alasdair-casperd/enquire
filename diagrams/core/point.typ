#import "@preview/cetz:0.4.2"

///
/// Mark the point `(x, y)` with a small filled circle.
///
#let point = (x, y, fill: black, name: none) => {
  cetz.draw.content(
    (x, y),
    circle(radius: 0.2em, fill: fill),
    name: name,
  )
}
