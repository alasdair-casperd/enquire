#import "@preview/cetz:0.4.2"
#import "../utilities/mid.typ": mid
#import "../utilities/vector-maths/mod.typ" as vec

#let eps = 1e-6

///
/// Directions (as angles) of every recorded segment leaving the point `p`. A
/// segment ending at `p` contributes one direction; a segment passing through
/// `p` contributes both.
///
#let incident-angles = (p, segments) => {
  let angles = ()
  for (a, b) in segments {
    let ab = vec.sub(b, a)
    let len = vec.magnitude(ab)
    if len < eps { continue }

    let ap = vec.sub(p, a)
    let cross = ab.at(0) * ap.at(1) - ab.at(1) * ap.at(0)
    let t = (ab.at(0) * ap.at(0) + ab.at(1) * ap.at(1)) / (len * len)

    // Skip segments that don't touch `p`
    if calc.abs(cross) / len > eps or t < -eps or t > 1 + eps { continue }

    if t < 1 - eps { angles.push(vec.angle(ab)) }
    if t > eps { angles.push(vec.angle(vec.scale(ab, -1))) }
  }
  return angles
}

///
/// Unit vector pointing from `p` into the emptiest region around it: the
/// bisector of the largest angular gap between recorded segments meeting at
/// `p`. Ties (e.g. a point in the middle of a straight line) are broken in
/// favour of pointing away from the centroid of everything drawn. Points
/// touching no segment point directly away from the centroid.
///
#let label-direction = (p, points, segments) => {
  let away = if points.len() > 0 { vec.sub(p, mid(..points)) } else { (0, 1) }
  if vec.magnitude(away) < eps { away = (0, 1) }
  away = vec.normalise(away)

  let angles = incident-angles(p, segments).sorted()
  if angles.len() == 0 { return away }

  // Gaps between consecutive directions, including the wrap-around gap
  let gaps = range(angles.len()).map(i => {
    let start = angles.at(i)
    let end = if i + 1 < angles.len() { angles.at(i + 1) } else { angles.first() + 360deg }
    (start, end - start)
  })

  let widest = calc.max(..gaps.map(g => g.at(1)))
  let bisectors = gaps
    .filter(g => g.at(1) > widest - 1deg)
    .map(((start, gap)) => {
      let theta = start + gap / 2
      (calc.cos(theta), calc.sin(theta))
    })

  let score = u => u.at(0) * away.at(0) + u.at(1) * away.at(1)
  return bisectors.sorted(key: u => -score(u)).first()
}

///
/// Distance to move the centre of a `w` by `h` box from `p` along the unit
/// vector `u` so that the nearest point of the box is exactly `gap` from `p`.
///
#let clearance = (u, w, h, gap) => {
  let (a, b) = (w / 2, h / 2)
  let (x, y) = (calc.abs(u.at(0)), calc.abs(u.at(1)))

  // Nearest point on a vertical edge
  if x > eps {
    let t = (a + gap) / x
    if t * y <= b { return t }
  }
  // Nearest point on a horizontal edge
  if y > eps {
    let t = (b + gap) / y
    if t * x <= a { return t }
  }
  // Nearest point is a corner: solve |t u - (a, b)| = gap
  let k = a * x + b * y
  return k + calc.sqrt(calc.max(0, k * k - (a * a + b * b - gap * gap)))
}

///
/// Size of `body` in canvas units, measured the same way Cetz sizes content
/// (cap-height to bounds, excluding padding), after rotation by `angle`.
///
#let content-size = (ctx, body, angle) => {
  let measure = b => cetz.util.measure(ctx, b)
  let flat = [#show linebreak: [ ]; #body]
  let (_, baseline-height) = measure(text(top-edge: "cap-height", bottom-edge: "baseline", flat))
  let (_, bounds-height) = measure(text(top-edge: "cap-height", bottom-edge: "bounds", flat))
  let (w, h) = measure(text(top-edge: "cap-height", bottom-edge: "baseline", body))
  h += bounds-height - baseline-height

  let (c, s) = (calc.abs(calc.cos(angle)), calc.abs(calc.sin(angle)))
  return (w * c + h * s, w * s + h * c)
}

///
/// Where to centre `body` so that it sits just outside whatever has been drawn
/// at `coordinates`, a constant `padding` away from the point in any
/// direction.
///
#let auto-position = (ctx, coordinates, body, angle, style) => {
  let (_, p) = cetz.coordinate.resolve(ctx, coordinates, update: false)
  let p = p.slice(0, 2)

  let shared-data = ctx.at("shared-data", default: (:))
  let u = label-direction(
    p,
    shared-data.at("points", default: ()),
    shared-data.at("segments", default: ()),
  )

  let padding = cetz.styles.resolve(ctx.style, merge: style, root: "content").padding
  let gap = calc.max(..cetz.util.as-padding-dict(padding).values().map(cetz.util.resolve-number.with(ctx)))

  let (w, h) = content-size(ctx, body, angle)
  return vec.add(p, vec.scale(u, clearance(u, w, h, gap)))
}
