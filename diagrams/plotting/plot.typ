#import "@preview/cetz:0.4.2"
#import "../core/draw.typ": draw
#import "../core/shape.typ": shape
#import "generate-plot-points.typ": generate-plot-points
#import "../parsing/evaluate-expression.typ": evaluate-expression
#import "../parsing/evaluate-ast.typ": evaluate-ast
#import "../parsing/decode-relation.typ": decode-relation, extract-bounds
#import "../patterns/mod.typ": patterns
#import "segment-utils.typ": clip-to-viewport, refine-domain-boundaries, split-at-discontinuities

///
/// Construct a region polygon from lower and upper bound curve segments.
/// Adds viewport corners when a bound is a viewport edge, to ensure the
/// region is filled completely without self-intersections.
///
#let make-region-polygon(lower-pts, upper-pts, x-min, x-max, y-min, y-max, swap-axes, lower-is-edge, upper-is-edge) = {
  if lower-pts.len() < 2 or upper-pts.len() < 2 {
    return none
  }

  // Build the polygon as: lower curve, corners (if needed), then the upper
  // curve reversed, then corners back to the start
  let region = lower-pts

  // Corners BETWEEN the lower and upper curves, to avoid self-intersection
  if swap-axes {
    // Swapped: filling horizontally, edges at x-min or x-max
    let lower-end = lower-pts.at(-1)
    let upper-end = upper-pts.at(-1)

    if lower-is-edge {
      // Lower bound is the left edge (x-min): add corners on the top side
      // to connect lower-end to upper-end
      if upper-end.at(0) > x-max - 0.01 {
        // Upper curve ends at the right edge: add the top-right corner
        region.push((x-max, y-max))
      } else if upper-end.at(1) < y-max - 0.01 {
        // Upper curve ends before y-max
        region.push((upper-end.at(0), y-max))
      }
    } else if upper-is-edge {
      // Upper bound is the right edge (x-max)
      if lower-end.at(1) < y-max - 0.01 {
        // Lower curve ends before y-max: add corners
        region.push((lower-end.at(0), y-max))
        region.push((x-max, y-max))
      }
    }
  } else {
    // Normal: filling vertically, edges at y-min or y-max
    let lower-end = lower-pts.at(-1)
    let upper-end = upper-pts.at(-1)

    if lower-is-edge {
      // Lower bound is the bottom edge (y-min): add corners on the right
      // side to connect lower-end to upper-end
      if upper-end.at(1) > y-max - 0.01 {
        // Upper curve ends at or near the top edge: add the top-right corner
        region.push((x-max, y-max))
      } else if upper-end.at(0) < x-max - 0.01 {
        // Upper curve ends before x-max: add the right edge up to the
        // curve's end
        region.push((x-max, y-min))
        region.push((x-max, upper-end.at(1)))
      }
    } else if upper-is-edge {
      // Upper bound is the top edge (y-max)
      if lower-end.at(0) < x-max - 0.01 {
        // Lower curve ends before x-max: add corners
        region.push((x-max, lower-end.at(1)))
        region.push((x-max, y-max))
      }
    }
  }

  // The reversed upper curve
  region = region + upper-pts.rev()

  // Corners closing the polygon back to its starting point
  if swap-axes {
    let upper-start = upper-pts.at(0)
    let lower-start = lower-pts.at(0)

    if lower-is-edge {
      // Lower bound is the left edge (x-min): add corners on the bottom side
      if upper-start.at(0) > x-max - 0.01 {
        // Upper curve starts at the right edge: add the bottom-right corner
        region.push((x-max, y-min))
      } else if upper-start.at(1) > y-min + 0.01 {
        // Upper curve starts after y-min
        region.push((upper-start.at(0), y-min))
      }
    } else if upper-is-edge {
      // Upper bound is the right edge (x-max): add corners on the left side
      if lower-start.at(0) < x-min + 0.01 {
        // Lower curve starts at or near the left edge: add the bottom-left
        // corner
        region.push((x-min, y-min))
      } else if lower-start.at(1) > y-min + 0.01 {
        // Lower curve starts after y-min
        region.push((x-min, lower-start.at(1)))
      }
    }
  } else {
    let upper-start = upper-pts.at(0)
    let lower-start = lower-pts.at(0)

    if lower-is-edge {
      // Lower bound is the bottom edge (y-min): add corners on the left side
      if upper-start.at(1) > y-max - 0.01 {
        // Upper curve starts at or near the top edge: add the top-left corner
        region.push((x-min, y-max))
      } else if upper-start.at(0) > x-min + 0.01 {
        // Upper curve starts after x-min
        region.push((x-min, upper-start.at(1)))
      }
    } else if upper-is-edge {
      // Upper bound is the top edge (y-max): add corners on the left side
      if lower-start.at(1) < y-min + 0.01 {
        // Lower curve starts at or near the bottom edge: add the bottom-left
        // corner
        region.push((x-min, y-min))
      } else if lower-start.at(0) > x-min + 0.01 {
        // Lower curve starts after x-min
        region.push((x-min, lower-start.at(1)))
      }
    }
  }

  return region
}

///
/// Plot a curve or shaded region. Must be drawn after a set of axes (which
/// record the viewport bounds).
///
/// The expression may be:
/// - an inequality (`$y > x^2$`, `$x < 2$`, `$1 < y < x + 1$`, ...), plotted
///   as a shaded region;
/// - an equation (`$y = x^2$` or `$x = y^2$`), plotted as a curve;
/// - a bare expression in x (`$x^2$`), plotted as y = f(x);
/// - a Typst function, plotted as y = f(x).
///
/// - domain: an optional `(min, max)` range for the independent variable
/// - resolution: the number of sampling steps across the domain
/// - discontinuity-threshold: the jump between consecutive samples (as a
///   fraction of the viewport) beyond which the curve is split
/// - auto-asymptotes: draw detected vertical asymptotes as dashed lines
/// - fill: fill pattern for regions (defaults to diagonal stripes)
/// - show-boundary: whether to draw boundary curves for regions
/// - boundary-style: style for region boundary curves (by default, strict
///   inequalities get dashed boundaries and non-strict ones solid)
///
#let plot = (
  expression,
  domain: none,
  resolution: 50,
  discontinuity-threshold: 0.3,
  auto-asymptotes: true,
  fill: none,
  show-boundary: true,
  boundary-style: (),
  ..style,
) => {
  cetz.draw.get-ctx(ctx => {
    // Viewport bounds, as recorded by `axes`
    let from = ctx.shared-data.from
    let to = ctx.shared-data.to
    let x-min = from.at(0)
    let x-max = to.at(0)
    let y-min = from.at(1)
    let y-max = to.at(1)

    // Parse the expression as a relation to detect inequalities
    let relation-result = if type(expression) != function {
      decode-relation(expression)
    } else {
      (type: "function")
    }

    let is-inequality = (
      relation-result.type == "relation"
        and {
          let ops = relation-result.relations.map(r => r.operator)
          ops.any(op => op in ("<", ">", "<=", ">="))
        }
    )

    if is-inequality {
      // REGION PLOTTING
      let bounds = extract-bounds(relation-result)

      if bounds == none {
        panic("Could not extract bounds from relation")
      }

      let bounded-var = bounds.variable
      let lower-bound-ast = bounds.lower
      let upper-bound-ast = bounds.upper

      // Bounds on x are handled by swapping the roles of the axes
      let swap-axes = bounded-var == "x"

      // Build the bound functions, falling back to the viewport edges for
      // one-sided inequalities
      let lower-func = none
      let upper-func = none

      if bounded-var == "y" {
        lower-func = if lower-bound-ast != none {
          x => evaluate-ast(lower-bound-ast, variables: ("x": x))
        } else {
          x => y-min
        }

        upper-func = if upper-bound-ast != none {
          x => evaluate-ast(upper-bound-ast, variables: ("x": x))
        } else {
          x => y-max
        }
      } else {
        lower-func = if lower-bound-ast != none {
          y => evaluate-ast(lower-bound-ast, variables: ("y": y))
        } else {
          y => x-min
        }

        upper-func = if upper-bound-ast != none {
          y => evaluate-ast(upper-bound-ast, variables: ("y": y))
        } else {
          y => x-max
        }
      }

      // Sample both bound curves
      let lower-points = generate-plot-points(
        lower-func,
        ctx,
        domain: domain,
        resolution: resolution,
        swap-axes: swap-axes,
      )
      let upper-points = generate-plot-points(
        upper-func,
        ctx,
        domain: domain,
        resolution: resolution,
        swap-axes: swap-axes,
      )

      // Split each bound at discontinuities (checking jumps along the
      // dependent axis)
      let disc-min = if swap-axes { x-min } else { y-min }
      let disc-max = if swap-axes { x-max } else { y-max }
      let check-coord = if swap-axes { 0 } else { 1 }

      let lower-segments = split-at-discontinuities(
        lower-points,
        disc-min,
        disc-max,
        threshold-factor: discontinuity-threshold,
        check-coord: check-coord,
      ).segments
      let upper-segments = split-at-discontinuities(
        upper-points,
        disc-min,
        disc-max,
        threshold-factor: discontinuity-threshold,
        check-coord: check-coord,
      ).segments

      // Pair up the bound segments and fill a region between each pair
      let num-regions = calc.min(lower-segments.len(), upper-segments.len())

      for i in range(num-regions) {
        let lower-clipped = clip-to-viewport(lower-segments.at(i), x-min, x-max, y-min, y-max)
        let upper-clipped = clip-to-viewport(upper-segments.at(i), x-min, x-max, y-min, y-max)

        for j in range(calc.min(lower-clipped.len(), upper-clipped.len())) {
          let lower-pts = lower-clipped.at(j)
          let upper-pts = upper-clipped.at(j)

          if lower-pts.len() >= 2 and upper-pts.len() >= 2 {
            let region-points = make-region-polygon(
              lower-pts,
              upper-pts,
              x-min,
              x-max,
              y-min,
              y-max,
              swap-axes,
              lower-bound-ast == none,
              upper-bound-ast == none,
            )

            if region-points != none {
              let region-fill = if fill == none { (patterns.stripes)() } else { fill }
              shape(..region-points, fill: region-fill, stroke: none, ..style)
            }
          }
        }
      }

      // Draw the boundary curves: dashed for strict inequalities, solid
      // otherwise
      if show-boundary {
        let lower-boundary-style = if boundary-style != () {
          boundary-style
        } else if bounds.lower-strict {
          (stroke: (dash: "dashed"))
        } else {
          ()
        }

        let upper-boundary-style = if boundary-style != () {
          boundary-style
        } else if bounds.upper-strict {
          (stroke: (dash: "dashed"))
        } else {
          ()
        }

        if lower-bound-ast != none {
          for seg in lower-segments {
            for sub-seg in clip-to-viewport(seg, x-min, x-max, y-min, y-max) {
              if sub-seg.len() >= 2 {
                draw(..sub-seg, ..lower-boundary-style)
              }
            }
          }
        }

        if upper-bound-ast != none {
          for seg in upper-segments {
            for sub-seg in clip-to-viewport(seg, x-min, x-max, y-min, y-max) {
              if sub-seg.len() >= 2 {
                draw(..sub-seg, ..upper-boundary-style)
              }
            }
          }
        }
      }
    } else {
      // CURVE PLOTTING
      let swap-axes = false
      let func = if type(expression) != function {
        if relation-result.type == "relation" and relation-result.single-relation {
          let rel = relation-result.relations.at(0)

          let is-y-equation = rel.operator == "=" and rel.left.type == "variable" and rel.left.id == "y"
          let is-x-equation = rel.operator == "=" and rel.left.type == "variable" and rel.left.id == "x"

          if is-y-equation {
            // y = f(x): plot the right-hand side as a function of x
            x => evaluate-ast(rel.right, variables: ("x": x))
          } else if is-x-equation {
            // x = f(y): plot the right-hand side as a function of y
            swap-axes = true
            y => evaluate-ast(rel.right, variables: ("y": y))
          } else {
            // Some other relation: treat the whole thing as an expression
            x => evaluate-expression(expression, variables: ("x": x))
          }
        } else {
          // A bare expression: plot as y = f(x)
          x => evaluate-expression(expression, variables: ("x": x))
        }
      } else {
        expression
      }

      let points = generate-plot-points(func, ctx, domain: domain, resolution: resolution, swap-axes: swap-axes)

      if points.len() >= 2 {
        // Split into segments at discontinuities (checking jumps along the
        // dependent axis)
        let disc-min = if swap-axes { x-min } else { y-min }
        let disc-max = if swap-axes { x-max } else { y-max }
        let check-coord = if swap-axes { 0 } else { 1 }

        let result = split-at-discontinuities(
          points,
          disc-min,
          disc-max,
          threshold-factor: discontinuity-threshold,
          check-coord: check-coord,
        )
        let segments = result.segments
        let asymptotes = result.asymptotes

        // Refine segment endpoints to capture behaviour at domain boundaries
        // (e.g. ln(x) as x approaches 0)
        segments = segments.map(seg => refine-domain-boundaries(seg, func, disc-min, disc-max, swap-axes: swap-axes))

        // Clip each segment to the viewport (which may split it further)
        let clipped-segments = ()
        for seg in segments {
          clipped-segments += clip-to-viewport(seg, x-min, x-max, y-min, y-max)
        }

        for segment in clipped-segments {
          if segment.len() >= 2 {
            draw(..segment, ..style)
          }
        }

        // Draw detected vertical asymptotes as dashed lines
        if auto-asymptotes {
          for x in asymptotes {
            draw((x, y-min), (x, y-max), stroke: (dash: "dashed"))
          }
        }
      }
    }
  })
}
