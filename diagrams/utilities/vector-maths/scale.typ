///
/// Scale a vector by a scalar.
///
#let scale = (v, scalar) => {
  return (v.at(0) * scalar, v.at(1) * scalar)
}
