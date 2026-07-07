// Segment utilities for handling discontinuities and boundary interpolation
// in plots.

///
/// Split points into segments at discontinuities, detected as large jumps
/// between consecutive points (indicating asymptotes).
///
/// - points: array of (x, y) coordinate pairs
/// - coord-min: viewport minimum coordinate (y for normal, x for swapped)
/// - coord-max: viewport maximum coordinate (y for normal, x for swapped)
/// - threshold-factor: fraction of the viewport size to use as the
///   discontinuity threshold
/// - check-coord: which coordinate index to check for jumps: 1 for y
///   (default), 0 for x
///
/// Returns a dictionary with "segments" (an array of point arrays) and
/// "asymptotes" (an array of coordinates along the independent axis).
///
#let split-at-discontinuities(points, coord-min, coord-max, threshold-factor: 0.3, check-coord: 1) = {
  if points.len() < 2 {
    return (
      segments: if points.len() == 0 { () } else { (points,) },
      asymptotes: ()
    )
  }

  let viewport-size = coord-max - coord-min
  if viewport-size <= 0 {
    return (
      segments: if points.len() >= 2 { (points,) } else { () },
      asymptotes: ()
    )
  }

  let threshold = viewport-size * threshold-factor
  let segments = ((),)  // Array of arrays
  let asymptotes = ()   // Array of asymptote locations

  segments.at(0).push(points.at(0))  // First point starts first segment

  for i in range(1, points.len()) {
    let prev = points.at(i - 1)
    let curr = points.at(i)
    let jump = calc.abs(curr.at(check-coord) - prev.at(check-coord))

    if jump > threshold {
      // Discontinuity detected - start new segment
      // Estimate asymptote location as midpoint along the independent axis
      let indep-coord = 1 - check-coord
      let asymptote-loc = (prev.at(indep-coord) + curr.at(indep-coord)) / 2
      asymptotes.push(asymptote-loc)
      segments.push((curr,))
    } else {
      // Continue current segment
      segments.at(-1).push(curr)
    }
  }

  // Filter out single-point segments
  (
    segments: segments.filter(seg => seg.len() >= 2),
    asymptotes: asymptotes
  )
}

///
/// Find where the line segment from `p1` to `p2` crosses a viewport boundary
/// using linear interpolation.
///
/// - boundary-value: the boundary coordinate value (e.g. y-min or x-max)
/// - is-y-boundary: true for a horizontal (y = value) boundary, false for a
///   vertical (x = value) one
///
/// Returns the interpolated crossing point, or `none` if the segment does
/// not cross the boundary.
///
#let interpolate-boundary(p1, p2, boundary-value, is-y-boundary) = {
  if is-y-boundary {
    // Interpolate to find x where y = boundary-value
    let y1 = p1.at(1)
    let y2 = p2.at(1)

    let crosses-boundary = (y1 <= boundary-value and y2 >= boundary-value) or (y1 >= boundary-value and y2 <= boundary-value)

    if crosses-boundary {
      let t = (boundary-value - y1) / (y2 - y1)
      let x = p1.at(0) + t * (p2.at(0) - p1.at(0))
      return (x, boundary-value)
    }
  } else {
    // Interpolate to find y where x = boundary-value
    let x1 = p1.at(0)
    let x2 = p2.at(0)

    let crosses-boundary = (x1 <= boundary-value and x2 >= boundary-value) or (x1 >= boundary-value and x2 <= boundary-value)

    if crosses-boundary {
      let t = (boundary-value - x1) / (x2 - x1)
      let y = p1.at(1) + t * (p2.at(1) - p1.at(1))
      return (boundary-value, y)
    }
  }

  return none
}

///
/// Clip a continuous curve segment to the viewport, splitting it at boundary
/// crossings. Returns an array of sub-segments, each within the viewport.
///
#let clip-to-viewport(segment, x-min, x-max, y-min, y-max) = {
  if segment.len() < 2 { return () }

  let is-inside(p) = {
    p.at(1) >= y-min and p.at(1) <= y-max and p.at(0) >= x-min and p.at(0) <= x-max
  }

  let find-boundary-crossing(p1, p2) = {
    // Find where line from p1 to p2 crosses viewport boundary
    // Check y boundaries first (more common for function plots)
    if p1.at(1) < y-min or p2.at(1) < y-min {
      let crossing = interpolate-boundary(p1, p2, y-min, true)
      if crossing != none { return crossing }
    }
    if p1.at(1) > y-max or p2.at(1) > y-max {
      let crossing = interpolate-boundary(p1, p2, y-max, true)
      if crossing != none { return crossing }
    }
    // Check x boundaries
    if p1.at(0) < x-min or p2.at(0) < x-min {
      let crossing = interpolate-boundary(p1, p2, x-min, false)
      if crossing != none { return crossing }
    }
    if p1.at(0) > x-max or p2.at(0) > x-max {
      let crossing = interpolate-boundary(p1, p2, x-max, false)
      if crossing != none { return crossing }
    }
    return none
  }

  let clipped-segments = ()
  let current-segment = ()

  for i in range(segment.len()) {
    let p = segment.at(i)
    let p-inside = is-inside(p)

    if i == 0 {
      // First point
      if p-inside {
        current-segment.push(p)
      }
    } else {
      let prev = segment.at(i - 1)
      let prev-inside = is-inside(prev)

      if prev-inside and p-inside {
        // Both inside - continue current segment
        current-segment.push(p)
      } else if prev-inside and not p-inside {
        // Exiting viewport - add crossing point and end segment
        let crossing = find-boundary-crossing(prev, p)
        if crossing != none {
          current-segment.push(crossing)
        }
        if current-segment.len() >= 2 {
          clipped-segments.push(current-segment)
        }
        current-segment = ()
      } else if not prev-inside and p-inside {
        // Entering viewport - start new segment at crossing point
        let crossing = find-boundary-crossing(prev, p)
        if crossing != none {
          current-segment.push(crossing)
        }
        current-segment.push(p)
      }
      // else both outside - skip both points
    }
  }

  // Add final segment if it has points
  if current-segment.len() >= 2 {
    clipped-segments.push(current-segment)
  }

  return clipped-segments
}

///
/// Refine segment endpoints near domain boundaries by sampling extra points
/// (with exponentially decreasing step size) beyond the segment's ends. This
/// captures behaviour where functions approach infinity or the edge of their
/// domain (e.g. ln(x) or sqrt(x) near 0).
///
/// - segment: array of (x, y) points
/// - func: the function being plotted
/// - dep-min: viewport minimum of the dependent variable
/// - dep-max: viewport maximum of the dependent variable
/// - max-samples: maximum number of extra samples to add at each end
/// - swap-axes: whether axes are swapped (x = f(y) instead of y = f(x))
///
#let refine-domain-boundaries(segment, func, dep-min, dep-max, max-samples: 10, swap-axes: false) = {
  if segment.len() < 2 { return segment }

  let result = segment

  // Determine which coordinate is independent (sampled) and which is dependent (computed)
  let indep-coord = if swap-axes { 1 } else { 0 }  // y if swapped, x if normal
  let dep-coord = if swap-axes { 0 } else { 1 }    // x if swapped, y if normal

  // Refine start of segment - sample backwards to capture approach to domain boundary
  let first = segment.at(0)
  let second = segment.at(1)
  let d-indep = first.at(indep-coord) - second.at(indep-coord)

  // Sample backwards with decreasing step size
  let backwards-points = ()
  let indep-val = first.at(indep-coord)
  let step = calc.abs(d-indep) * 0.5

  for i in range(max-samples) {
    indep-val = indep-val - step
    let dep-val = func(indep-val)

    if dep-val == none {
      // Hit domain boundary, stop
      break
    }

    let tolerance = (dep-max - dep-min) * 0.1
    if dep-val < dep-min - tolerance or dep-val > dep-max + tolerance {
      // Gone too far outside viewport, stop
      let point = if swap-axes { (dep-val, indep-val) } else { (indep-val, dep-val) }
      backwards-points.push(point)
      break
    }

    let point = if swap-axes { (dep-val, indep-val) } else { (indep-val, dep-val) }
    backwards-points.push(point)
    step = step * 0.5  // Exponentially decrease step size
  }

  // Add backwards points in reverse order (so they come before first point)
  if backwards-points.len() > 0 {
    result = backwards-points.rev() + result
  }

  // Refine end of segment - sample forwards
  let last = segment.at(-1)
  let second-last = if segment.len() >= 2 { segment.at(-2) } else { last }
  d-indep = last.at(indep-coord) - second-last.at(indep-coord)

  let forwards-points = ()
  indep-val = last.at(indep-coord)
  step = calc.abs(d-indep) * 0.5

  for i in range(max-samples) {
    indep-val = indep-val + step
    let dep-val = func(indep-val)

    if dep-val == none {
      // Hit domain boundary, stop
      break
    }

    let tolerance = (dep-max - dep-min) * 0.1
    if dep-val < dep-min - tolerance or dep-val > dep-max + tolerance {
      // Gone too far outside viewport, stop
      let point = if swap-axes { (dep-val, indep-val) } else { (indep-val, dep-val) }
      forwards-points.push(point)
      break
    }

    let point = if swap-axes { (dep-val, indep-val) } else { (indep-val, dep-val) }
    forwards-points.push(point)
    step = step * 0.5
  }

  if forwards-points.len() > 0 {
    result = result + forwards-points
  }

  return result
}
