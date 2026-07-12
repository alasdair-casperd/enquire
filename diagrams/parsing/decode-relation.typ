#import "decode-expression.typ": decode-expression

///
/// Parse a relation expression like `$y < x^2$` or `$1 < y < x+1$`.
///
/// Relations are detected by scanning the children of the expression for
/// relation operators; the content between operators is parsed as an
/// expression with `decode-expression`.
///
/// Returns either
///   (type: "expression", ast: ...)
/// when no relation operator is present, or
///   (type: "relation", relations: ((operator: "<", left: ..., right: ...), ...), single-relation: bool)
///
#let decode-relation(expr) = {
  // Simple approach: check if the expression contains relation operators
  // by examining its children array

  if type(expr) != content {
    // Not content, treat as expression
    return (
      type: "expression",
      ast: decode-expression(expr)
    )
  }

  // Math content ($...$) has a body field, not children
  let children = if expr.has("body") {
    if expr.body.has("children") {
      expr.body.children
    } else {
      ()
    }
  } else if expr.has("children") {
    expr.children
  } else {
    ()
  }

  if children.len() == 0 {
    // No children, treat as expression
    return (
      type: "expression",
      ast: decode-expression(expr)
    )
  }
  let rel-indices = ()
  let rel-operators = ()

  // Scan children for relation operators
  for i in range(children.len()) {
    let child = children.at(i)

    if type(child) == content and child.func() != none {
      let fname = repr(child.func())

      // Check for relation operators in symbol or op elements
      if child.has("text") and type(child.text) == str {
        let txt = child.text
        if txt in ("=", "<", ">", "≤", "≥", "<=", ">=", "!=", "≠") {
          let normalized = if txt == "≤" { "<=" }
                           else if txt == "≥" { ">=" }
                           else if txt == "≠" { "!=" }
                           else { txt }
          rel-indices.push(i)
          rel-operators.push(normalized)
        }
      } else if fname.contains("eq.lt.eq") {
        rel-indices.push(i)
        rel-operators.push("<=")
      } else if fname.contains("eq.gt.eq") {
        rel-indices.push(i)
        rel-operators.push(">=")
      } else if fname.contains("eq.lt") and not fname.contains("eq.lt.eq") {
        rel-indices.push(i)
        rel-operators.push("<")
      } else if fname.contains("eq.gt") and not fname.contains("eq.gt.eq") {
        rel-indices.push(i)
        rel-operators.push(">")
      } else if fname.contains("eq.eq") {
        rel-indices.push(i)
        rel-operators.push("=")
      }
    }
  }

  // If no relations found, treat as expression
  if rel-operators.len() == 0 {
    return (
      type: "expression",
      ast: decode-expression(expr)
    )
  }

  // Build relations by splitting at relation operators
  let relations = ()

  for i in range(rel-operators.len()) {
    let rel-idx = rel-indices.at(i)

    // Determine left operand
    let left-start = if i == 0 { 0 } else { rel-indices.at(i - 1) + 1 }
    let left-end = rel-idx

    // Determine right operand
    let right-start = rel-idx + 1
    let right-end = if i + 1 < rel-operators.len() {
      rel-indices.at(i + 1)
    } else {
      children.len()
    }

    // Extract left and right content
    let left-children = ()
    for j in range(left-start, left-end) {
      left-children.push(children.at(j))
    }

    let right-children = ()
    for j in range(right-start, right-end) {
      right-children.push(children.at(j))
    }

    // Create content from children
    let left-content = if left-children.len() == 1 {
      left-children.at(0)
    } else if left-children.len() > 1 {
      left-children.join()
    } else {
      []
    }

    let right-content = if right-children.len() == 1 {
      right-children.at(0)
    } else if right-children.len() > 1 {
      right-children.join()
    } else {
      []
    }

    // Parse as expressions
    let left-ast = if i == 0 {
      decode-expression(left-content)
    } else {
      // For chained relations, left is the right of previous
      relations.at(i - 1).right
    }

    let right-ast = decode-expression(right-content)

    relations.push((
      operator: rel-operators.at(i),
      left: left-ast,
      right: right-ast
    ))
  }

  return (
    type: "relation",
    relations: relations,
    single-relation: relations.len() == 1
  )
}

///
/// Extract bounds from a relation (the result of `decode-relation`) for
/// region plotting.
///
/// Returns a dictionary with:
///   - variable: "x" or "y" (which variable is bounded)
///   - lower: lower/left bound AST (or none)
///   - upper: upper/right bound AST (or none)
///   - lower-strict: whether the lower bound is strict (true for <, false for <=)
///   - upper-strict: whether the upper bound is strict (true for <, false for <=)
/// or `none` if no bounds could be found.
///
#let extract-bounds(relation-result) = {
  if relation-result.type != "relation" { return none }

  let relations = relation-result.relations

  if relations.len() == 1 {
    // Single relation: check which variable is bounded
    let rel = relations.at(0)

    let is-strict = rel.operator in ("<", ">")

    // Try y variable first
    if rel.left.type == "variable" and rel.left.id == "y" {
      if rel.operator in ("<", "<=") {
        return (variable: "y", lower: none, upper: rel.right, lower-strict: false, upper-strict: is-strict)  // y < f(x)
      } else if rel.operator in (">", ">=") {
        return (variable: "y", lower: rel.right, upper: none, lower-strict: is-strict, upper-strict: false)  // y > f(x)
      } else if rel.operator == "=" {
        return (variable: "y", lower: rel.right, upper: rel.right, lower-strict: false, upper-strict: false)  // y = f(x)
      }
    }

    if rel.right.type == "variable" and rel.right.id == "y" {
      if rel.operator in ("<", "<=") {
        return (variable: "y", lower: rel.left, upper: none, lower-strict: is-strict, upper-strict: false)  // f(x) < y
      } else if rel.operator in (">", ">=") {
        return (variable: "y", lower: none, upper: rel.left, lower-strict: false, upper-strict: is-strict)  // f(x) > y
      }
    }

    // Try x variable
    if rel.left.type == "variable" and rel.left.id == "x" {
      if rel.operator in ("<", "<=") {
        return (variable: "x", lower: none, upper: rel.right, lower-strict: false, upper-strict: is-strict)  // x < f(y)
      } else if rel.operator in (">", ">=") {
        return (variable: "x", lower: rel.right, upper: none, lower-strict: is-strict, upper-strict: false)  // x > f(y)
      } else if rel.operator == "=" {
        return (variable: "x", lower: rel.right, upper: rel.right, lower-strict: false, upper-strict: false)  // x = f(y)
      }
    }

    if rel.right.type == "variable" and rel.right.id == "x" {
      if rel.operator in ("<", "<=") {
        return (variable: "x", lower: rel.left, upper: none, lower-strict: is-strict, upper-strict: false)  // f(y) < x
      } else if rel.operator in (">", ">=") {
        return (variable: "x", lower: none, upper: rel.left, lower-strict: false, upper-strict: is-strict)  // f(y) > x
      }
    }
  } else if relations.len() == 2 {
    // Chained relation: check which variable is in the middle
    let rel1 = relations.at(0)
    let rel2 = relations.at(1)

    // Check for y in middle: f(x) < y < g(x)
    let is-y-chained = rel1.right.type == "variable" and rel1.right.id == "y" and rel2.left.type == "variable" and rel2.left.id == "y"

    if is-y-chained {
      return (variable: "y", lower: rel1.left, upper: rel2.right, lower-strict: rel1.operator in ("<", ">"), upper-strict: rel2.operator in ("<", ">"))
    }

    // Check for x in middle: f(y) < x < g(y)
    let is-x-chained = rel1.right.type == "variable" and rel1.right.id == "x" and rel2.left.type == "variable" and rel2.left.id == "x"

    if is-x-chained {
      return (variable: "x", lower: rel1.left, upper: rel2.right, lower-strict: rel1.operator in ("<", ">"), upper-strict: rel2.operator in ("<", ">"))
    }
  }

  return none
}
