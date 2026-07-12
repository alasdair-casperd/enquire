#import "translate.typ": translate

///
/// Scale a set of vertices by a given scale factor about a pivot.
///
/// - pivot: the centre of enlargement (defaults to the first vertex)
/// - x, y: set to `false` to leave that axis unscaled
///
#let scale = (vertices, factor, pivot: none, x: true, y: true) => {
  // If no pivot is provided, use the first vertex in the list
  if pivot == none {
    pivot = vertices.at(0)
  }

  // Translate the pivot to the origin
  vertices = translate(vertices, (-pivot.at(0), -pivot.at(1)))

  // Scale about the origin
  let x-factor = if x { factor } else { 1 }
  let y-factor = if y { factor } else { 1 }
  vertices = vertices.map(v => (v.at(0) * x-factor, v.at(1) * y-factor))

  // Reverse the original translation
  vertices = translate(vertices, (pivot.at(0), pivot.at(1)))

  return vertices
}
