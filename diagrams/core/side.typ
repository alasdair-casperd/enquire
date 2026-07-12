#import "@preview/cetz:0.4.2"
#import "point.typ": point as draw-point
#import "../utilities/mid.typ": mid
#import "../utilities/vector-maths/mod.typ" as vec
#import "../utilities/suggest-anchor.typ": suggest-anchor

///
/// Label the side of a shape running from `a` to `b`.
///
/// The label is placed at the midpoint of the side and automatically nudged
/// away from the shape: the centroid of all points drawn so far (as recorded
/// by `draw` and `shape`) is used to decide which side of the line counts as
/// "outside".
///
/// - point: `true` to also mark the midpoint with a small filled circle
///
#let side = (
  a,
  b,
  content,
  angle: 0deg,
  name: none,
  point: false,
  ..style,
) => {
  cetz.draw.get-ctx(ctx => {
    let coordinates = mid(a, b)

    // Points previously drawn on this canvas (recorded by `draw`)
    let points = ctx.at("shared-data", default: (:)).at("points", default: ())

    let anchor = none

    if points.len() > 0 {
      let center = mid(..points)

      // Unit normal to the side
      let ab = vec.sub(b, a)
      let normal = vec.normalise((ab.at(1), -ab.at(0)))

      // Pick the normal direction that points away from the shape's centroid
      let option-1 = vec.add(coordinates, normal)
      let option-2 = vec.sub(coordinates, normal)
      let outward = if (
        vec.magnitude(vec.sub(option-1, center)) >= vec.magnitude(vec.sub(option-2, center))
      ) {
        normal
      } else {
        vec.scale(normal, -1)
      }

      // Anchor the label on its shape-facing edge, pushing the content
      // outward from the shape
      anchor = suggest-anchor(vec.scale(outward, -1))
    }

    cetz.draw.content(coordinates, content, angle: angle, name: name, anchor: anchor, ..style)

    // Optionally mark the midpoint itself
    if point {
      draw-point(..coordinates)
    }
  })
}
