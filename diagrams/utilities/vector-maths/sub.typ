///
/// Subtract vector `v` from vector `u`.
///
#let sub = (u, v) => {
  return (u.at(0) - v.at(0), u.at(1) - v.at(1))
}
