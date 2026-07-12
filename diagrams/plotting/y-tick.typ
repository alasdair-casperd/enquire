#import "../core/node.typ": node

///
/// Draw a y-axis tick mark and label at each of the given y values.
///
/// - label: content to display beside each tick (defaults to the value)
/// - x-origin: the x coordinate of the axis
/// - tick-length: the visual length of the tick mark
/// - axis-color: colour for the tick and label
/// - font-scale: font size for the label
///
#let y-tick = (
  ..values,
  label: auto,
  x-origin: 0,
  tick-length: 0.3em,
  axis-color: black,
  font-scale: 0.8em,
) => {
  for value in values.pos() {
    let display = if label == auto { $#value$ } else { label }
    node(
      (x-origin, value),
      line(angle: 180deg, length: tick-length, stroke: axis-color + 0.7pt),
      anchor: "east",
      padding: 0,
    )
    node((x-origin, value), text(size: font-scale, display, fill: axis-color), anchor: "east", padding: 0.4em)
  }
}

///
/// Draw y-axis tick marks and labels at multiples of `tick-step` over the
/// range `from` to `to`.
///
/// - tick-origin: a value that ticks are aligned to
/// - skip-zero: whether to omit the tick at 0 (to avoid colliding with the
///   x-axis)
///
#let create-y-ticks = (
  from,
  to,
  x-origin: 0,
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
      y-tick(
        t,
        x-origin: x-origin,
        tick-length: tick-length,
        axis-color: axis-color,
        font-scale: font-scale,
      )
    }
    t += tick-step
  }
}
