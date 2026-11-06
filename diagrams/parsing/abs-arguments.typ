///
/// Collect the argument of every modulus (`abs`) node in an AST produced by
/// `decode-expression`, including nested ones. For `||x| - 2|` this returns
/// the ASTs of `|x| - 2` and `x`.
///
/// A modulus graph can only have a sharp corner where one of these arguments
/// changes sign, so plotting uses them to place points exactly on corners.
///
#let abs-arguments(ast) = {
  if type(ast) != dictionary or "type" not in ast { return () }

  if ast.type == "unary-operation" {
    let inner = abs-arguments(ast.parameter)
    if ast.id == "abs" and ast.parameter != none {
      (ast.parameter,) + inner
    } else {
      inner
    }
  } else if ast.type == "binary-operation" {
    abs-arguments(ast.left) + abs-arguments(ast.right)
  } else {
    ()
  }
}
