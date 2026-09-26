#import "@preview/cetz:0.4.2"
#import "../core/draw.typ": draw
#import "../core/node.typ": node
#import "../utilities/mid.typ": mid
#import "x-tick.typ": create-x-ticks
#import "y-tick.typ": create-y-ticks

///
/// Normalise a grid step given as a number, an `(x, y)` array or an
/// `(x: ..., y: ...)` dictionary into a dictionary.
///
#let extract-grid-step = (step, default: 1) => {
  let x = default
  let y = default
  if type(step) in (int, float) {
    x = step
    y = step
  }
  if type(step) == array {
    x = step.at(0)
    y = step.at(1)
  }
  if type(step) == dictionary {
    x = step.at("x", default: default)
    y = step.at("y", default: default)
  }
  return (x: x, y: y)
}

///
/// The cetz grid `shift` that places a grid line through `center`. cetz
/// starts the grid at `from` and offsets it by the shift modulo the step.
/// (An array is returned because cetz 0.4.2 mishandles a dictionary shift.)
///
#let grid-shift = (from, center) => (
  center.x - from.at(0),
  center.y - from.at(1),
)

///
/// Draw a set of axes spanning the rectangle between `from` and `to`.
///
/// The viewport bounds are recorded in the canvas' shared data and as the
/// anchors "from" and "to"; `plot` and `plot-line` rely on these, so axes
/// must be drawn before any plots.
///
/// - grid: whether to draw a grid
/// - grid-step: spacing of grid lines (a number, `(x, y)` array or dictionary)
/// - grid-center: a point that grid lines pass through, whether or not it
///   lies within the viewport (a number, `(x, y)` array or dictionary);
///   defaults to the origin
/// - major-grid-step: spacing of major grid lines, in multiples of the
///   minor grid step, or `none` for no major grid
/// - faded: draw the axes in a light grey (useful for background axes)
/// - x-description / y-description: a description displayed alongside the
///   axis label
/// - x-tick-origin / y-tick-origin: a value that ticks are aligned to
/// - x-scale / y-scale: scale factors applied to the whole canvas
///
#let axes = (
  from: (-5, -5),
  to: (5, 5),
  grid: false,
  grid-style: (:),
  grid-step: 1,
  grid-center: (0, 0),
  major-grid-step: none,
  major-grid-style: (stroke: 0.5pt + gray),
  axis-color: black,
  faded: false,
  x-axis: true,
  x-label: $x$,
  x-description: none,
  x-description-offset: 2.5em,
  x-ticks: false,
  x-tick-step: 1,
  x-tick-origin: 0,
  x-tick-length: 0.3em,
  x-scale: 1,
  y-axis: true,
  y-label: $y$,
  y-description: none,
  y-description-offset: 2.5em,
  y-ticks: false,
  y-tick-step: 1,
  y-tick-origin: 0,
  y-tick-length: 0.3em,
  y-scale: 1,
  tick-font-scale: 0.8em,
) => {
  // Apply scale
  cetz.draw.scale(x: x-scale, y: y-scale)

  // Grid lines pass through `grid-center` rather than starting at `from`
  let center = extract-grid-step(grid-center, default: 0)
  let shift = grid-shift(from, center)

  // Minor grid
  if grid {
    cetz.draw.grid(
      from,
      to,
      help-lines: true,
      step: grid-step,
      shift: shift,
      ..grid-style,
    )
  }

  // Major grid, with a step given in multiples of the minor grid step
  if major-grid-step != none {
    let major-step = extract-grid-step(major-grid-step)
    let minor-step = extract-grid-step(grid-step)
    cetz.draw.grid(
      from,
      to,
      step: (x: major-step.x * minor-step.x, y: major-step.y * minor-step.y),
      shift: shift,
      ..major-grid-style,
    )
  }

  if faded { axis-color = rgb(170, 170, 170) }

  // x-axis
  if x-axis {
    // Clamp the axis to the viewport if the origin lies outside it
    let y-origin = 0
    if from.at(1) > 0 { y-origin = from.at(1) }
    if to.at(1) < 0 { y-origin = to.at(1) }

    draw((from.at(0), y-origin), (to.at(0), y-origin), mark: (end: ">", fill: axis-color), stroke: axis-color)
    node((to.at(0), y-origin), text(x-label, fill: axis-color), anchor: "north")

    if x-description != none {
      node(
        mid((from.at(0), y-origin), (to.at(0), y-origin)),
        move(dy: x-description-offset)[#x-description],
      )
    }

    if x-ticks {
      create-x-ticks(
        from.at(0),
        to.at(0),
        y-origin: y-origin,
        tick-origin: x-tick-origin,
        tick-step: x-tick-step,
        tick-length: x-tick-length,
        axis-color: axis-color,
        skip-zero: y-axis,
        font-scale: tick-font-scale,
      )
    }
  }

  // y-axis
  if y-axis {
    // Clamp the axis to the viewport if the origin lies outside it
    let x-origin = 0
    if from.at(0) > 0 { x-origin = from.at(0) }
    if to.at(0) < 0 { x-origin = to.at(0) }

    draw((x-origin, from.at(1)), (x-origin, to.at(1)), mark: (end: ">", fill: axis-color), stroke: axis-color)
    node((x-origin, to.at(1)), text(y-label, fill: axis-color), anchor: "east")

    if y-description != none {
      node(
        mid((x-origin, from.at(1)), (x-origin, to.at(1))),
        move(dy: -y-description-offset)[#y-description],
        angle: 90deg,
      )
    }

    if y-ticks {
      create-y-ticks(
        from.at(1),
        to.at(1),
        x-origin: x-origin,
        tick-origin: y-tick-origin,
        tick-step: y-tick-step,
        tick-length: y-tick-length,
        axis-color: axis-color,
        skip-zero: x-axis,
        font-scale: tick-font-scale,
      )
    }
  }

  // Record the viewport bounds in the canvas' shared data for use by `plot`
  cetz.draw.set-ctx(ctx => {
    let shared-data = ctx.at("shared-data", default: (:))
    shared-data.insert("from", from)
    shared-data.insert("to", to)
    ctx.insert("shared-data", shared-data)
    return ctx
  })

  // Anchors marking the viewport corners, used by `plot-line` for clipping
  cetz.draw.anchor("from", from)
  cetz.draw.anchor("to", to)
}
