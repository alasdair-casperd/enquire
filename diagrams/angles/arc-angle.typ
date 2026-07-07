#import "@preview/cetz:0.4.2"
#import cetz.angle: angle as cetz-angle

///
/// Mark the angle at `origin` between the rays towards `a` and `b`, sweeping
/// anticlockwise from `b` to `a`. Wrapper around Cetz's `angle`.
///
/// - label: content to display beside the arc
///
#let arc-angle = (a, origin, b, label: [], name: none, ..style) => {
  cetz-angle(origin, b, a, label: label, name: name, ..style)
}
