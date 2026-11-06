///
/// Sample a function over the current viewport, returning an array of
/// `(x, y)` points.
///
/// - function: the function to sample
/// - ctx: the Cetz context (the viewport bounds are read from the shared
///   data recorded by `axes`)
/// - domain: an optional `(min, max)` sampling range for the independent
///   variable; `none`/`auto` entries fall back to the viewport bounds
/// - resolution: the number of sampling steps across the domain
/// - swap-axes: sample x = f(y) instead of y = f(x)
/// - critical: functions of the independent variable whose sign changes
///   mark points that must be sampled exactly, such as the corners of a
///   modulus graph (where the argument of `|...|` crosses zero). Without
///   these, corners falling between samples would be cut off.
///
#let generate-plot-points = (
  function,
  ctx,
  domain: none,
  resolution: 50,
  swap-axes: false,
  critical: (),
) => {
  let from = ctx.shared-data.from
  let to = ctx.shared-data.to

  // Bounds of the independent (sampled) and dependent (computed) variables
  let indep-axis = if swap-axes { 1 } else { 0 }
  let dep-axis = 1 - indep-axis
  let indep-min = from.at(indep-axis)
  let indep-max = to.at(indep-axis)
  let dep-min = from.at(dep-axis)
  let dep-max = to.at(dep-axis)

  // A custom domain overrides the viewport bounds
  if domain != none {
    if domain.at(0) not in (none, auto) { indep-min = domain.at(0) }
    if domain.at(1) not in (none, auto) { indep-max = domain.at(1) }
  }

  // Keep points slightly outside the viewport so that clipping can
  // interpolate accurate boundary crossings
  let tolerance = (dep-max - dep-min) * 0.1

  let step = (indep-max - indep-min) / resolution
  let samples = range(resolution + 1).map(i => indep-min + i * step)

  // Add a sample wherever a critical function changes sign between two
  // neighbouring samples, located by bisection
  if critical.len() > 0 {
    let refined = (samples.at(0),)
    for i in range(1, samples.len()) {
      let a = samples.at(i - 1)
      let b = samples.at(i)
      let roots = ()

      for g in critical {
        let ga = g(a)
        let gb = g(b)
        if ga == none or gb == none or ga * gb >= 0 { continue }

        let lo = a
        let hi = b
        let g-lo = ga
        for iteration in range(40) {
          let mid = (lo + hi) / 2
          let g-mid = g(mid)
          if g-mid == none { break }
          if g-mid == 0 {
            lo = mid
            hi = mid
            break
          }
          if (g-mid < 0) == (g-lo < 0) {
            lo = mid
            g-lo = g-mid
          } else {
            hi = mid
          }
        }
        roots.push((lo + hi) / 2)
      }

      refined += roots.sorted()
      refined.push(b)
    }
    samples = refined
  }

  let points = ()

  for indep in samples {
    let dep = function(indep)

    // Skip samples where the function is undefined or far outside the
    // viewport
    if dep == none { continue }
    if dep > dep-max + tolerance or dep < dep-min - tolerance { continue }

    points.push(if swap-axes { (dep, indep) } else { (indep, dep) })
  }

  points
}
