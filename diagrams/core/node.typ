#import "@preview/cetz:0.4.2"
#import "point.typ": point as draw-point
#import "auto-anchor.typ": auto-position

///
/// Place content at a position on the canvas. Wrapper around Cetz's
/// `content`.
///
/// - anchor: a Cetz anchor name (e.g. "north", "center"), or `auto` to place
///   the content just outside whatever has been drawn through the position
///   (as recorded by `draw` and `shape`), a constant distance from it in any
///   direction
/// - point: `true` to also mark the position with a small filled circle, or
///   custom content to draw at the position instead
///
#let node = (
  coordinates,
  content,
  angle: 0deg,
  anchor: auto,
  name: none,
  point: false,
  ..style,
) => {
  if anchor == auto {
    cetz.draw.get-ctx(ctx => {
      let position = auto-position(ctx, coordinates, content, angle, style.named())
      cetz.draw.content(position, content, angle: angle, anchor: "center", name: name, ..style)
    })
  } else {
    cetz.draw.content(coordinates, content, angle: angle, anchor: anchor, name: name, ..style)
  }

  // Optionally mark the position itself
  if type(point) == bool {
    if point {
      draw-point(..coordinates)
    }
  } else {
    cetz.draw.content(coordinates, point)
  }
}

///
/// Label several positions at once, each placed automatically just outside
/// whatever has been drawn through it (see `node` with `anchor: auto`).
///
/// - labels: an array of content, one per position; `none` skips a label
/// - points: `true` to also mark each position with a small filled circle,
///   or custom content to draw at each position instead
///
#let nodes = (..coordinates-style, labels: (), points: false) => {
  let coordinates = coordinates-style.pos()
  assert(
    labels.len() == coordinates.len(),
    message: "nodes: expected " + str(coordinates.len()) + " labels, got " + str(labels.len()),
  )

  for (coordinates, label) in coordinates.zip(labels) {
    if label != none {
      node(coordinates, label, ..coordinates-style.named())
    }

    // Optionally mark the position itself
    if type(points) == bool {
      if points {
        draw-point(..coordinates)
      }
    } else {
      cetz.draw.content(coordinates, points)
    }
  }
}
