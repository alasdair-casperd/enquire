///
/// Calculate the point of intersection of two lines, each defined by a pair
/// of points. Returns `none` if the lines are parallel.
///
#let intersection(line1, line2) = {
  let ((x1, y1), (x2, y2)) = line1
  let ((x3, y3), (x4, y4)) = line2

  let denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)

  // Parallel (or coincident) lines have no unique intersection
  if denom == 0 { return none }

  let t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom

  (x1 + t * (x2 - x1), y1 + t * (y2 - y1))
}
