///
/// Calculate the magnitude of a vector.
///
#let magnitude = v => {
  return calc.sqrt(calc.pow(v.at(0), 2) + calc.pow(v.at(1), 2))
}
