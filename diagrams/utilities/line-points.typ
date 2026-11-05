#import "../parsing/decode-relation.typ": decode-relation
#import "../parsing/evaluate-ast.typ": evaluate-ast

///
/// Give two distinct points on the straight line described by an equation,
/// e.g. `line-points($x = -1$)` gives `((-1.0, 0), (-1.0, 1))`. The reverse of
/// `line-equation`.
///
/// Works for any linear equation in x and y (`$y = 2x + 1$`, `$x + y = 3$`,
/// `$2y = x - 4$`, ...).
///
#let line-points(equation) = {
  let rel = decode-relation(equation)
  assert(
    rel.type == "relation" and rel.single-relation and rel.relations.at(0).operator == "=",
    message: "line-points expects a single equation, e.g. $y = 2x + 1$",
  )
  let (left, right) = rel.relations.at(0)

  // Write the equation as f(x, y) = 0, where f(x, y) = ax + by + c
  let f(x, y) = {
    let variables = (x: x, y: y)
    evaluate-ast(left, variables: variables) - evaluate-ast(right, variables: variables)
  }
  let c = f(0, 0)
  let a = f(1, 0) - c
  let b = f(0, 1) - c

  if b != 0 {
    // Solve for y at x = 0 and x = 1
    ((0, -c / b), (1, -(a + c) / b))
  } else if a != 0 {
    // Vertical line: x is constant
    ((-c / a, 0), (-c / a, 1))
  } else {
    panic("line-points: equation does not describe a line")
  }
}
