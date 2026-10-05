///
/// A tiling of crossed diagonal lines, for shading regions.
///
#let crosshatch = (stroke: rgb(0, 0, 0, 100) + 0.5pt, size: 5pt) => tiling(size: (size, size))[
  // Three parallel diagonals in each direction so that the lines join up
  // seamlessly across tile boundaries
  #place(line(start: (0%, 0%), end: (100%, 100%), stroke: stroke))
  #place(line(start: (0%, -100%), end: (200%, 100%), stroke: stroke))
  #place(line(start: (-100%, 0%), end: (100%, 200%), stroke: stroke))
  #place(line(start: (100%, 0%), end: (0%, 100%), stroke: stroke))
  #place(line(start: (100%, -100%), end: (-100%, 100%), stroke: stroke))
  #place(line(start: (200%, 0%), end: (0%, 200%), stroke: stroke))
]
