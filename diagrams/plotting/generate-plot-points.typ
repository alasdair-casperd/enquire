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
///
#let generate-plot-points = (
  function,
  ctx,
  domain: none,
  resolution: 50,
  swap-axes: false,
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

  let points = ()
  let step = (indep-max - indep-min) / resolution

  for i in range(resolution + 1) {
    let indep = indep-min + i * step
    let dep = function(indep)

    // Skip samples where the function is undefined or far outside the
    // viewport
    if dep == none { continue }
    if dep > dep-max + tolerance or dep < dep-min - tolerance { continue }

    points.push(if swap-axes { (dep, indep) } else { (indep, dep) })
  }

  points
}
