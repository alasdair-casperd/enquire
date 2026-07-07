///
/// Calculate the angle of a vector, measured anticlockwise from the positive
/// x direction, in the range (-180deg, 180deg].
///
#let angle = v => calc.atan2(v.at(0), v.at(1))
