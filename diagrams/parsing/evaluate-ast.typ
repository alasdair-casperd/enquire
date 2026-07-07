///
/// Evaluate an AST produced by `decode-expression` at the given variable
/// values (e.g. `variables: ("x": 2)`).
///
/// Returns `none` wherever the expression is undefined or not real (division
/// by zero, square roots of negatives, logarithms of non-positive values,
/// ...) so that plotting code can simply skip those samples rather than
/// panicking.
///
#let evaluate-ast(ast, variables: (:)) = {
  if ast == none { return none }

  if ast.type == "number" {
    ast.value
  } else if ast.type == "constant" {
    if ast.id == "pi" {
      calc.pi
    } else if ast.id == "e" {
      calc.e
    } else {
      none
    }
  } else if ast.type == "variable" {
    if ast.id in variables {
      variables.at(ast.id)
    } else {
      none
    }
  } else if ast.type == "binary-operation" {
    let left = evaluate-ast(ast.left, variables: variables)
    let right = evaluate-ast(ast.right, variables: variables)

    if left == none or right == none { return none }

    if ast.id == "plus" {
      left + right
    } else if ast.id == "minus" {
      left - right
    } else if ast.id == "times" {
      left * right
    } else if ast.id == "divide" {
      if right == 0 { none } else { left / right }
    } else if ast.id == "power" {
      if left < 0 and calc.fract(right) != 0 {
        // Not real: fractional power of a negative number
        none
      } else if left == 0 and right < 0 {
        // Division by zero
        none
      } else if left != 0 and right * calc.ln(calc.abs(left)) > 700 {
        // Would overflow a float
        none
      } else {
        calc.pow(left, right)
      }
    } else if ast.id == "root" {
      if right == 0 {
        none
      } else if left < 0 {
        // Negative radicands only have real roots for odd integer indices
        if calc.fract(right) == 0 and calc.rem(calc.abs(right), 2) == 1 {
          -calc.pow(-left, 1.0 / right)
        } else {
          none
        }
      } else {
        calc.pow(left, 1.0 / right)
      }
    } else {
      none
    }
  } else if ast.type == "unary-operation" {
    let param = evaluate-ast(ast.parameter, variables: variables)

    if param == none { return none }

    if ast.id == "sqrt" {
      if param < 0 {
        none
      } else {
        calc.sqrt(param)
      }
    } else if ast.id == "sin" {
      calc.sin(param)
    } else if ast.id == "cos" {
      calc.cos(param)
    } else if ast.id == "tan" {
      calc.tan(param)
    } else if ast.id == "ln" {
      if param <= 0 {
        none
      } else {
        calc.ln(param)
      }
    } else if ast.id == "log" {
      if param <= 0 {
        none
      } else {
        calc.log(param)
      }
    } else if ast.id == "exp" {
      // Guard against float overflow
      if param > 700 { none } else { calc.exp(param) }
    } else if ast.id == "abs" {
      calc.abs(param)
    } else if ast.id == "csc" {
      // Cosecant: 1/sin(x), undefined when sin(x) = 0
      let sin-val = calc.sin(param)
      if calc.abs(sin-val) < 1e-10 { none } else { 1.0 / sin-val }
    } else if ast.id == "sec" {
      // Secant: 1/cos(x), undefined when cos(x) = 0
      let cos-val = calc.cos(param)
      if calc.abs(cos-val) < 1e-10 { none } else { 1.0 / cos-val }
    } else if ast.id == "cot" {
      // Cotangent: cos(x)/sin(x), undefined when sin(x) = 0
      let sin-val = calc.sin(param)
      if calc.abs(sin-val) < 1e-10 { none } else { calc.cos(param) / sin-val }
    } else if ast.id in ("arcsin", "asin") {
      // Inverse sine: domain [-1, 1], returns radians as a float
      if param < -1 or param > 1 { none } else { calc.asin(param) / 1rad }
    } else if ast.id in ("arccos", "acos") {
      // Inverse cosine: domain [-1, 1], returns radians as a float
      if param < -1 or param > 1 { none } else { calc.acos(param) / 1rad }
    } else if ast.id in ("arctan", "atan") {
      // Inverse tangent: returns radians as a float
      calc.atan(param) / 1rad
    } else if ast.id in ("sinh", "cosh", "tanh") {
      // Hyperbolic functions, via their exponential definitions
      if calc.abs(param) > 700 {
        // calc.exp would overflow; tanh saturates, the others diverge
        if ast.id == "tanh" {
          if param > 0 { 1.0 } else { -1.0 }
        } else {
          none
        }
      } else {
        let e-plus = calc.exp(param)
        let e-minus = calc.exp(-param)
        if ast.id == "sinh" {
          (e-plus - e-minus) / 2
        } else if ast.id == "cosh" {
          (e-plus + e-minus) / 2
        } else {
          (e-plus - e-minus) / (e-plus + e-minus)
        }
      }
    } else {
      none
    }
  } else {
    none
  }
}
