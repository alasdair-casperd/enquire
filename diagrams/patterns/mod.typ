#import "stripes-pattern.typ": stripes
#import "dots-pattern.typ": dots

// Ready-made fill patterns for shaded regions, e.g.
// `plot($y > x^2$, fill: (patterns.dots)())`
#let patterns = (
  stripes: stripes,
  dots: dots,
)
