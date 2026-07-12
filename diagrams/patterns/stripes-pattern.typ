///
/// A tiling of diagonal stripes, for shading regions.
///
#let stripes = (stroke: rgb(0, 0, 0, 100) + 0.5pt, size: 5pt) => tiling(size: (size, size))[
  // Three parallel diagonals so that the stripes join up seamlessly across
  // tile boundaries
  #place(line(start: (0%, 0%), end: (100%, 100%), stroke: stroke))
  #place(line(start: (0%, -100%), end: (200%, 100%), stroke: stroke))
  #place(line(start: (-100%, 0%), end: (100%, 200%), stroke: stroke))
]
