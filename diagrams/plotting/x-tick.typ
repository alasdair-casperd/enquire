#import "../core/node.typ": node

///
/// Draw an x-axis tick mark and label at each of the given x values.
///
/// - label: content to display below each tick (defaults to the value)
/// - y-origin: the y coordinate of the axis
/// - tick-length: the visual length of the tick mark
/// - axis-color: colour for the tick and label
/// - font-scale: font size for the label
///
#let x-tick = (
  ..values,
  label: auto,
  y-origin: 0,
  tick-length: 0.3em,
  axis-color: black,
  font-scale: 0.8em,
) => {
  for value in values.pos() {
    let display = if label == auto { $#value$ } else { label }
    node(
      (value, y-origin),
      line(angle: 90deg, length: tick-length, stroke: axis-color + 0.7pt),
      anchor: "north",
      padding: 0,
    )
    node((value, y-origin), text(size: font-scale, display, fill: axis-color), anchor: "north", padding: 0.4em)
  }
}

///
/// Draw x-axis tick marks and labels at multiples of `tick-step` over the
/// range `from` to `to`.
///
/// - tick-origin: a value that ticks are aligned to
/// - skip-zero: whether to omit the tick at 0 (to avoid colliding with the
///   y-axis)
///
#let create-x-ticks = (
  from,
  to,
  y-origin: 0,
  tick-origin: 0,
  tick-step: 1,
  tick-length: 0.3em,
  axis-color: black,
  skip-zero: true,
  font-scale: 0.8em,
) => {
  assert(tick-step > 0, message: "tick-step must be positive")

  // Find the first tick position at or after `from`
  let t = tick-origin
  while t < from {
    t += tick-step
  }
  while t - tick-step > from {
    t -= tick-step
  }

  while t < to {
    if t != 0 or not skip-zero {
      x-tick(
        t,
        y-origin: y-origin,
        tick-length: tick-length,
        axis-color: axis-color,
        font-scale: font-scale,
      )
    }
    t += tick-step
  }
}
