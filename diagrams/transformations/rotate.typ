#import "translate.typ": translate

///
/// Rotate a set of vertices clockwise about a pivot through a given angle.
///
#let rotate = (vertices, angle, pivot) => {
  // Translate the pivot to the origin
  vertices = translate(vertices, (-pivot.at(0), -pivot.at(1)))

  // Rotate about the origin
  let c = calc.cos(angle)
  let s = calc.sin(angle)
  vertices = vertices.map(v => (v.at(0) * c + v.at(1) * s, -v.at(0) * s + v.at(1) * c))

  // Reverse the original translation
  vertices = translate(vertices, (pivot.at(0), pivot.at(1)))

  return vertices
}
