#import "magnitude.typ": *
#import "scale.typ": *

///
/// Normalise a vector to unit length. The zero vector is returned unchanged.
///
#let normalise = v => {
  let m = magnitude(v)
  if m == 0 { return (0, 0) }
  return scale(v, 1 / m)
}
