#import "draw.typ": draw
#import "../utilities/mid.typ": mid
#import "../utilities/vector-maths/mod.typ" as vec

///
/// Draw tick marks across the midpoint of a line, to indicate sides of equal
/// length.
///
/// - count: the number of tick marks to draw
/// - length: the length of each tick, in canvas units
/// - spacing: the distance between adjacent ticks, in canvas units
///
#let line-tick = (
  start,
  end,
  count: 1,
  length: 0.3,
  spacing: 0.15,
) => {
  let direction = vec.normalise(vec.sub(end, start))
  let gap-vector = vec.scale(direction, spacing)

  // Centre the row of ticks on the midpoint of the line
  let tick-position = vec.add(mid(start, end), vec.scale(gap-vector, -(count - 1) / 2))

  // Each tick runs perpendicular to the line
  let tick-vector = vec.scale((direction.at(1), -direction.at(0)), length * 0.5)

  for i in range(count) {
    draw(vec.add(tick-position, tick-vector), vec.sub(tick-position, tick-vector))
    tick-position = vec.add(tick-position, gap-vector)
  }
}
