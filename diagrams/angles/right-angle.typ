#import "@preview/cetz:0.4.2"
#import cetz.angle: right-angle as cetz-right-angle

///
/// Mark the right angle at `origin` between the rays towards `a` and `b`.
/// Wrapper around Cetz's `right-angle`.
///
#let right-angle = (a, origin, b, name: none, radius: 0.8em, ..style) => {
  cetz-right-angle(origin, a, b, label: [], name: name, radius: radius, ..style)
}
