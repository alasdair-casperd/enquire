#import "@preview/cetz:0.4.2"
#import "../utilities/vector-maths/mod.typ" as vec

///
/// Draw arrowheads along a line, to indicate parallel sides.
///
/// - count: the number of arrowheads to draw
/// - position: the fraction along the line at which the arrowheads are
///   centred
/// - spacing: the distance between adjacent arrowheads, in canvas units
/// - scale: scale factor for the arrowhead stroke
/// - mark: additional Cetz mark style options
///
#let line-arrow = (
  start,
  end,
  count: 1,
  position: 0.5,
  spacing: 0.2,
  scale: 1,
  fill: black,
  mark: (:),
) => {
  let line-vector = vec.sub(end, start)
  let direction = vec.normalise(line-vector)
  let gap-vector = vec.scale(direction, spacing)

  // Centre the row of arrowheads at the requested position along the line
  let base = vec.add(start, vec.scale(line-vector, position))
  let arrow-pos = vec.add(base, vec.scale(gap-vector, -(count - 1) / 2))

  let mark-style = (symbol: ">", anchor: "center", fill: fill, stroke: scale * 0.15em + fill) + mark

  for i in range(count) {
    cetz.draw.mark(arrow-pos, vec.add(arrow-pos, direction), ..mark-style)
    arrow-pos = vec.add(arrow-pos, gap-vector)
  }
}
