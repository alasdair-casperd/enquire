#import "vector-maths/mod.typ" as vec

///
/// Convert polar coordinates to a cartesian point: the point at distance
/// `radius` from `center` (the origin by default), at `angle` anticlockwise
/// from the positive x direction.
///
/// ```typst
/// polar(2, 60deg)                 // (1, 1.73)
/// polar(1, 90deg, center: (3, 0)) // (3, 1)
/// ```
///
#let polar = (radius, angle, center: (0, 0)) => (
  center.at(0) + radius * calc.cos(angle),
  center.at(1) + radius * calc.sin(angle),
)

///
/// Convert a cartesian point to polar coordinates about `center` (the origin
/// by default), returning a `(radius, angle)` pair with the angle measured
/// anticlockwise from the positive x direction, in the range
/// (-180deg, 180deg].
///
#let to-polar = (point, center: (0, 0)) => {
  let v = vec.sub(point, center)
  (vec.magnitude(v), vec.angle(v))
}
