#import "draw.typ": draw

///
/// Draw a shape through the given vertices. Identical to `draw`, but closed
/// by default.
///
#let shape = (
  ..pts-style,
  close: true,
  name: none,
) => {
  draw(..pts-style, close: close, name: name)
}
