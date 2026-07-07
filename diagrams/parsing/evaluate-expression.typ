#import "decode-expression.typ": decode-expression
#import "evaluate-ast.typ": evaluate-ast

///
/// Evaluate a Typst maths expression at the given variable values, e.g.
/// `evaluate-expression($x^2 + 1$, variables: ("x": 2))`.
///
/// Returns `none` where the expression is undefined (see `evaluate-ast`).
///
#let evaluate-expression = (expression, variables: (:)) => evaluate-ast(
  decode-expression(expression),
  variables: variables,
)
