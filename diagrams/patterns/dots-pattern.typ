///
/// A tiling of small dots, for shading regions.
///
#let dots = (fill: rgb(0, 0, 0, 100), size: 5pt, radius: 0.5pt) => tiling(size: (size, size))[
  #place(center + horizon, circle(radius: radius, fill: fill, stroke: none))
]
