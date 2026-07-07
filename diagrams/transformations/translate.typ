///
/// Translate a set of vertices by a given vector.
///
#let translate = (vertices, translation) => {
  return vertices.map(v => {
    (v.at(0) + translation.at(0), v.at(1) + translation.at(1))
  })
}
