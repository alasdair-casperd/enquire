#import "@preview/cetz:0.4.2"
#import "../utilities/vector-maths/mod.typ" as vec

///
/// Plot the straight line passing through two points, extended in both
/// directions and clipped to the viewport. Must be drawn after a set of
/// axes (which record the viewport bounds), and the line must actually
/// cross the viewport.
///
#let plot-line = (
  start,
  end,
  ..style,
) => {
  // Extend the segment far beyond any sensible viewport...
  let v = vec.sub(end, start)
  let extension = 1000 / calc.max(vec.magnitude(v), 1e-6)
  let far-start = vec.sub(start, vec.scale(v, extension))
  let far-end = vec.add(end, vec.scale(v, extension))

  // ...then clip it by intersecting with the viewport rectangle recorded by
  // `axes` as the anchors "from" and "to"
  cetz.draw.intersections("i", {
    cetz.draw.hide(cetz.draw.line(far-start, far-end, name: "line"))
    cetz.draw.hide(cetz.draw.rect("from", "to", name: "axis-bounds"))
  })
  cetz.draw.line("i.0", "i.1", ..style)
}

// The former name of `plot-line`, kept as an alias
#let straight-line = plot-line
