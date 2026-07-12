///
/// Compute the midpoint (centroid) of any number of vertices.
///
#let mid = (..vertices) => {
  let n = vertices.pos().len()
  assert(n > 0, message: "mid requires at least one vertex")

  let output = (0, 0)
  for v in vertices.pos() {
    output = (output.at(0) + v.at(0), output.at(1) + v.at(1))
  }
  return (output.at(0) / n, output.at(1) / n)
}
