///
/// Give the equation of the straight line through two points, as maths
/// content in the form `y = mx + c` (or `x = a` for vertical lines).
///
#let line-equation(p1, p2) = {
  let (x1, y1) = p1
  let (x2, y2) = p2

  // Vertical line
  if x1 == x2 {
    return $x = #(x1)$
  }

  // Horizontal line
  if y1 == y2 {
    return $y = #(y1)$
  }

  // General case
  let m = (y2 - y1) / (x2 - x1)
  let b = y1 - m * x1

  // Display gradients of 1 and -1 without a coefficient
  let m-display = m
  if m == 1 { m-display = [] }
  if m == -1 { m-display = $-$ }

  // Pretty formatting for the sign of the intercept
  if b > 0 {
    $y = #(m-display)x + #(b)$
  } else if b < 0 {
    $y = #(m-display)x - #(-b)$
  } else {
    $y = #(m-display)x$
  }
}
