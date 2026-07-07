///
/// Suggest a Cetz anchor name for content given the direction (a roughly
/// unit vector) in which the content's anchored edge should face. For
/// example, the direction (0, 1) yields "north", so the content extends
/// downwards, away from whatever lies above it.
///
#let suggest-anchor = direction => {
  let tol = 0.4
  let (x, y) = direction

  // Snap each component to -1, 0 or 1
  let h = if x > tol { 1 } else if x < -tol { -1 } else { 0 }
  let v = if y > tol { 1 } else if y < -tol { -1 } else { 0 }

  let vertical = if v == 1 { "north" } else if v == -1 { "south" } else { "" }
  let horizontal = if h == 1 { "east" } else if h == -1 { "west" } else { "" }
  let dash = if h != 0 and v != 0 { "-" } else { "" }

  return vertical + dash + horizontal
}
