#import "@preview/cetz:0.4.2"
#import "point.typ": point as draw-point

///
/// Place content at a position on the canvas. Wrapper around Cetz's
/// `content`.
///
/// - point: `true` to also mark the position with a small filled circle, or
///   custom content to draw at the position instead
///
#let node = (
  coordinates,
  content,
  angle: 0deg,
  name: none,
  point: false,
  ..style,
) => {
  cetz.draw.content(coordinates, content, angle: angle, name: name, ..style)

  // Optionally mark the position itself
  if type(point) == bool {
    if point {
      draw-point(..coordinates)
    }
  } else {
    cetz.draw.content(coordinates, point)
  }
}
