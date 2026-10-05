#import "stripes-pattern.typ": stripes
#import "dots-pattern.typ": dots
#import "crosshatch-pattern.typ": crosshatch

// Ready-made fill patterns for shaded regions, e.g.
// `plot($y > x^2$, fill: (patterns.dots)())`
#let patterns = (
  stripes: stripes,
  dots: dots,
  crosshatch: crosshatch,
)
