///
/// Reflect a set of vertices in the mirror line defined by a pair of points.
///
#let reflect = (points, line) => {
  let p1 = line.at(0)
  let p2 = line.at(1)
  let (x1, y1) = (p1.at(0), p1.at(1))
  let (x2, y2) = (p2.at(0), p2.at(1))

  // Direction vector of the mirror line
  let dx = x2 - x1
  let dy = y2 - y1
  let len2 = dx * dx + dy * dy
  assert(len2 != 0, message: "the two points defining the mirror line must be distinct")

  points.map(point => {
    let (px, py) = (point.at(0), point.at(1))

    // Project the point onto the mirror line...
    let t = ((px - x1) * dx + (py - y1) * dy) / len2
    let projx = x1 + t * dx
    let projy = y1 + t * dy

    // ...then reflect it through its projection
    (2 * projx - px, 2 * projy - py)
  })
}
