///
/// Sum any number of vectors.
///
#let add = (..vectors) => {
  let output = (0, 0)
  for v in vectors.pos() {
    output = (output.at(0) + v.at(0), output.at(1) + v.at(1))
  }
  return output
}
