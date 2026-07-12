///
/// Decode a Typst maths expression (e.g. `$x^2 + sin(x)$`) into an abstract
/// syntax tree that `evaluate-ast` can evaluate numerically.
///
/// The decoder works in three stages:
///   1. The content tree of the equation is flattened into a token stream.
///   2. Implicit multiplication tokens are inserted (e.g. `2x` -> `2 * x`).
///   3. The tokens are parsed into an AST with the usual operator precedence:
///      `^` binds tightest (right-associative), then `*` and `/`, then `+`
///      and `-`.
///
/// AST nodes are dictionaries of one of the following forms:
///   (type: "number", value: 2.0)
///   (type: "constant", id: "pi")
///   (type: "variable", id: "x")
///   (type: "unary-operation", id: "sin", parameter: ...)
///   (type: "binary-operation", id: "plus", left: ..., right: ...)
///
#let decode-expression(expr) = {
  let is-num(val) = type(val) in (int, float)

  // Greek letter names are accepted as variable names
  let greek = (
    "alpha",
    "beta",
    "gamma",
    "delta",
    "epsilon",
    "zeta",
    "eta",
    "theta",
    "iota",
    "kappa",
    "lambda",
    "mu",
    "nu",
    "xi",
    "pi",
    "rho",
    "sigma",
    "tau",
    "upsilon",
    "phi",
    "chi",
    "psi",
    "omega",
  )

  // Map Greek symbols to their names
  let greek-symbols = (
    "α": "alpha",
    "β": "beta",
    "γ": "gamma",
    "δ": "delta",
    "ε": "epsilon",
    "ζ": "zeta",
    "η": "eta",
    "θ": "theta",
    "ι": "iota",
    "κ": "kappa",
    "λ": "lambda",
    "μ": "mu",
    "ν": "nu",
    "ξ": "xi",
    "π": "pi",
    "ρ": "rho",
    "σ": "sigma",
    "τ": "tau",
    "υ": "upsilon",
    "φ": "phi",
    "χ": "chi",
    "ψ": "psi",
    "ω": "omega",
  )

  // Recognised function names
  let func-names = (
    "sin", "cos", "tan",            // basic trigonometric
    "csc", "sec", "cot",            // reciprocal trigonometric
    "arcsin", "asin",               // inverse sine
    "arccos", "acos",               // inverse cosine
    "arctan", "atan",               // inverse tangent
    "sinh", "cosh", "tanh",         // hyperbolic
    "ln", "log", "exp", "abs",      // logarithmic and other
  )

  // Recognised mathematical constants
  let constants = ("pi", "e")

  // Extract the plain-text name from an element with a `text` field (such as
  // the `op` elements Typst produces for `sin`, `cos`, ...)
  let text-of = c => {
    if type(c.text) == content and c.text.has("text") {
      c.text.text
    } else if type(c.text) == str {
      c.text
    } else {
      none
    }
  }

  // Classify a piece of text (an operator, relation, number, variable, ...)
  // and append the corresponding token, if any
  let tokenize-text = (txt, tokens) => {
    if txt.trim() == "" or txt in ("(", ")") {
      // Skip whitespace and stray parentheses: grouping is represented
      // structurally by `lr` elements, which are handled separately
    } else if txt in ("+", "−", "-", "*", "∗", "/", "÷", "×") {
      let normalized = if txt == "−" { "-" } else if txt == "∗" { "*" } else { txt }
      tokens.push(("op", normalized))
    } else if txt in ("=", "<", ">", "≤", "≥", "<=", ">=", "!=", "≠") {
      let normalized = if txt == "≤" { "<=" } else if txt == "≥" { ">=" } else if txt == "≠" { "!=" } else { txt }
      tokens.push(("rel", normalized))
    } else if txt.match(regex("^[0-9]+\.?[0-9]*$")) != none {
      tokens.push(("num", float(txt)))
    } else if txt in greek-symbols {
      // A Greek symbol: use its name, treating π as a constant
      let name = greek-symbols.at(txt)
      tokens.push(if name in constants { ("const", name) } else { ("var", name) })
    } else if txt in constants {
      tokens.push(("const", txt))
    } else if txt.len() == 1 and txt.first() in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" {
      tokens.push(("var", txt))
    } else if txt in greek {
      tokens.push(("var", txt))
    }
    tokens
  }

  let tokenizer = (
    // Tokenize the children of a sequence element. This deals with the
    // constructs that span multiple children: function application
    // (`sin x`, `sin(x)`) and function power notation (`sin^2 x`).
    tokenize-sequence: (self, children, tokens) => {
      let i = 0

      while i < children.len() {
        let c = children.at(i)

        // Function power notation, e.g. `sin^2 x`: an attach element whose
        // base is (or starts with) a function name
        if c.func() != none and repr(c.func()).contains("attach") and c.has("base") and c.has("t") {
          let base = c.base

          // Typst may group `sin x` as a sequence before attaching the `^2`
          if base.func() != none and repr(base.func()).contains("sequence") and base.has("children") {
            let base-children = base.children
            if base-children.len() > 0 {
              let first = base-children.at(0)
              if first.func() != none and repr(first.func()).contains("op") and first.has("text") {
                let txt = text-of(first)

                if txt != none and txt in func-names and base-children.len() > 1 {
                  // Emit (func arg) ^ (exponent)
                  tokens.push(("lparen", none))
                  tokens.push(("func", txt))
                  tokens = (self.tokenize)(self, base-children.at(1), tokens)
                  tokens.push(("rparen", none))
                  tokens.push(("op", "^"))
                  // Parenthesise the exponent to preserve its grouping
                  tokens.push(("lparen", none))
                  tokens = (self.tokenize)(self, c.t, tokens)
                  tokens.push(("rparen", none))

                  i += 1
                  continue
                }
              }
            }
          }

          // Otherwise the base may be a bare function name, with the
          // argument following as the next sibling (e.g. `sin^2 (x + 1)`)
          if base.func() != none and repr(base.func()).contains("op") and base.has("text") {
            let txt = text-of(base)

            if txt != none and txt in func-names {
              // Find the next non-whitespace sibling to act as the argument
              let next-idx = i + 1
              let next = none

              while next-idx < children.len() {
                let candidate = children.at(next-idx)
                // Space elements are content without a meaningful text field
                let is-whitespace = false
                if type(candidate) == content {
                  if not candidate.has("text") {
                    is-whitespace = true
                  } else {
                    let txt-val = candidate.text
                    if type(txt-val) == str {
                      is-whitespace = txt-val.trim() == ""
                    } else if type(txt-val) == content and txt-val.has("text") and type(txt-val.text) == str {
                      is-whitespace = txt-val.text.trim() == ""
                    }
                  }
                }

                if is-whitespace {
                  next-idx += 1
                } else {
                  next = candidate
                  break
                }
              }

              if next != none {
                // Emit (func arg) ^ (exponent)
                tokens.push(("lparen", none))
                tokens.push(("func", txt))

                if next.func() != none and repr(next.func()).contains("lr") and next.has("body") {
                  // Explicitly parenthesised argument
                  tokens.push(("lparen", none))
                  tokens = (self.tokenize)(self, next.body, tokens)
                  tokens.push(("rparen", none))
                } else {
                  tokens = (self.tokenize)(self, next, tokens)
                }

                tokens.push(("rparen", none))
                tokens.push(("op", "^"))
                // Parenthesise the exponent to preserve its grouping
                tokens.push(("lparen", none))
                tokens = (self.tokenize)(self, c.t, tokens)
                tokens.push(("rparen", none))

                i = next-idx + 1
                continue
              }
            }
          }
        }

        // Plain function application, e.g. `sin x` or `sin(x)`
        if c.func() != none and repr(c.func()).contains("op") and c.has("text") {
          let txt = text-of(c)

          if txt != none and txt in func-names {
            if i + 1 < children.len() {
              let next = children.at(i + 1)

              tokens.push(("func", txt))
              if next.func() != none and repr(next.func()).contains("lr") and next.has("body") {
                // Parenthesised argument: sin(x)
                tokens.push(("lparen", none))
                tokens = (self.tokenize)(self, next.body, tokens)
                tokens.push(("rparen", none))
              } else {
                // Bare argument: sin x
                tokens = (self.tokenize)(self, next, tokens)
              }
              i += 2
              continue
            }

            // No argument following: treat the name as a variable
            tokens.push(("var", txt))
            i += 1
          } else {
            tokens = (self.tokenize)(self, c, tokens)
            i += 1
          }
        } else {
          tokens = (self.tokenize)(self, c, tokens)
          i += 1
        }
      }

      tokens
    },

    // Tokenize a single piece of content, recursing into its structure
    tokenize: (self, c, tokens) => {
      if c == none { return tokens }

      let t = type(c)

      if t == content {
        let f = c.func()

        if f != none {
          let fname-repr = repr(f)
          let fname = if fname-repr.contains(".") {
            fname-repr.split(".").last().trim(")")
          } else {
            fname-repr.trim("<").trim(">")
          }

          if fname == "equation" and c.has("body") {
            tokens = (self.tokenize)(self, c.body, tokens)
          } else if fname == "sequence" and c.has("children") {
            tokens = (self.tokenize-sequence)(self, c.children, tokens)
          } else if fname == "attach" {
            // Superscript: base ^ (exponent). The exponent is parenthesised
            // because Typst strips explicit parentheses inside scripts
            // (`e^(x+1)` arrives as a bare sequence) and nested attaches
            // (`e^x^2` means e^(x^2)) would otherwise lose their grouping.
            if c.has("base") {
              tokens = (self.tokenize)(self, c.base, tokens)
            }
            if c.has("t") {
              tokens.push(("op", "^"))
              tokens.push(("lparen", none))
              tokens = (self.tokenize)(self, c.t, tokens)
              tokens.push(("rparen", none))
            }
          } else if fname == "root" {
            if c.has("index") {
              // General root: root(n, x) becomes a binary operation
              tokens.push(("root-start", none))
              tokens = (self.tokenize)(self, c.radicand, tokens)
              tokens.push(("root-mid", none))
              tokens = (self.tokenize)(self, c.index, tokens)
              tokens.push(("root-end", none))
            } else {
              // Square root: sqrt(x) becomes a unary operation
              tokens.push(("func", "sqrt"))
              tokens.push(("lparen", none))
              if c.has("radicand") {
                tokens = (self.tokenize)(self, c.radicand, tokens)
              }
              tokens.push(("rparen", none))
            }
          } else if fname == "frac" {
            // Fraction: (numerator) / (denominator)
            tokens.push(("lparen", none))
            if c.has("num") {
              tokens = (self.tokenize)(self, c.num, tokens)
            }
            tokens.push(("rparen", none))
            tokens.push(("op", "/"))
            tokens.push(("lparen", none))
            if c.has("denom") {
              tokens = (self.tokenize)(self, c.denom, tokens)
            }
            tokens.push(("rparen", none))
          } else if fname == "lr" and c.has("body") {
            // Explicit parentheses
            tokens.push(("lparen", none))
            tokens = (self.tokenize)(self, c.body, tokens)
            tokens.push(("rparen", none))
          } else if c.has("text") and type(c.text) == str {
            tokens = tokenize-text(c.text, tokens)
          } else if c.has("children") {
            for child in c.children {
              tokens = (self.tokenize)(self, child, tokens)
            }
          }
        } else if c.has("text") and type(c.text) == str {
          tokens = tokenize-text(c.text, tokens)
        } else if c.has("children") {
          for child in c.children {
            tokens = (self.tokenize)(self, child, tokens)
          }
        }
      } else if is-num(c) {
        tokens.push(("num", c))
      }

      tokens
    },
  )

  // Insert explicit multiplication tokens between adjacent factors, so that
  // e.g. `2x`, `x(x+1)` and `3 sin x` parse as products
  let add-implicit-mult(tokens) = {
    let result = ()
    for i in range(tokens.len()) {
      result.push(tokens.at(i))
      if i < tokens.len() - 1 {
        let curr = tokens.at(i)
        let next = tokens.at(i + 1)
        let needs-mult = (
          (curr.at(0) in ("num", "var", "rparen", "const") and next.at(0) in ("var", "lparen", "func", "const"))
            or (curr.at(0) == "var" and next.at(0) == "num")
        )
        if needs-mult {
          result.push(("op", "*"))
        }
      }
    }
    result
  }

  // A recursive descent parser over the token stream. Each rule takes a
  // position and returns an (ast, new-position) pair, with ast `none` on
  // failure.
  let parser = (
    // Atoms: numbers, constants, variables, parenthesised expressions,
    // function applications, roots and unary minus
    primary: (self, tokens, pos) => {
      if pos >= tokens.len() { return (none, pos) }

      let tok = tokens.at(pos)

      if tok.at(0) == "num" {
        ((type: "number", value: tok.at(1)), pos + 1)
      } else if tok.at(0) == "const" {
        ((type: "constant", id: tok.at(1)), pos + 1)
      } else if tok.at(0) == "var" {
        ((type: "variable", id: tok.at(1)), pos + 1)
      } else if tok.at(0) == "lparen" {
        let (node, new-pos) = (self.expr)(self, tokens, pos + 1)
        if new-pos < tokens.len() and tokens.at(new-pos).at(0) == "rparen" {
          (node, new-pos + 1)
        } else {
          (node, new-pos)
        }
      } else if tok.at(0) == "func" {
        let fname = tok.at(1)
        let (arg, new-pos) = (self.primary)(self, tokens, pos + 1)
        ((type: "unary-operation", id: fname, parameter: arg), new-pos)
      } else if tok.at(0) == "root-start" {
        // Parse: root-start radicand root-mid index root-end
        let (radicand, pos1) = (self.expr)(self, tokens, pos + 1)
        if pos1 >= tokens.len() or tokens.at(pos1).at(0) != "root-mid" {
          return (none, pos)
        }
        let (index, pos2) = (self.expr)(self, tokens, pos1 + 1)
        if pos2 >= tokens.len() or tokens.at(pos2).at(0) != "root-end" {
          return (none, pos)
        }
        ((type: "binary-operation", id: "root", left: radicand, right: index), pos2 + 1)
      } else if tok == ("op", "-") {
        // Unary minus at primary level (e.g. in exponents like e^-x)
        let (node, new-pos) = (self.primary)(self, tokens, pos + 1)
        if node == none { return (none, pos) }
        ((type: "binary-operation", id: "times", left: (type: "number", value: -1), right: node), new-pos)
      } else {
        (none, pos)
      }
    },

    // Powers. `^` is right-associative: x^y^z parses as x^(y^z)
    power: (self, tokens, pos) => {
      let (left, pos) = (self.primary)(self, tokens, pos)
      if left == none { return (none, pos) }

      if pos < tokens.len() and tokens.at(pos) == ("op", "^") {
        let (right, new-pos) = (self.power)(self, tokens, pos + 1)
        if right == none { return (left, pos) }
        return ((type: "binary-operation", id: "power", left: left, right: right), new-pos)
      }

      (left, pos)
    },

    // Products and quotients
    factor: (self, tokens, pos) => {
      let (left, pos) = (self.power)(self, tokens, pos)
      if left == none { return (none, pos) }

      while pos < tokens.len() {
        let tok = tokens.at(pos)
        if tok.at(0) == "op" and tok.at(1) in ("*", "/", "×", "÷") {
          let op-id = if tok.at(1) in ("*", "×") { "times" } else { "divide" }
          let (right, new-pos) = (self.power)(self, tokens, pos + 1)
          if right == none { return (left, pos) }
          left = (type: "binary-operation", id: op-id, left: left, right: right)
          pos = new-pos
        } else {
          break
        }
      }

      (left, pos)
    },

    // Sums and differences
    expr: (self, tokens, pos) => {
      // A leading minus negates the first term: parse as (-1) * factor
      let negate = pos < tokens.len() and tokens.at(pos) == ("op", "-")
      let start = if negate { pos + 1 } else { pos }

      let (left, pos) = (self.factor)(self, tokens, start)
      if left == none { return (none, pos) }
      if negate {
        left = (type: "binary-operation", id: "times", left: (type: "number", value: -1), right: left)
      }

      while pos < tokens.len() {
        let tok = tokens.at(pos)
        if tok.at(0) == "op" and tok.at(1) in ("+", "-") {
          let op-id = if tok.at(1) == "+" { "plus" } else { "minus" }
          let (right, new-pos) = (self.factor)(self, tokens, pos + 1)
          if right == none { return (left, pos) }
          left = (type: "binary-operation", id: op-id, left: left, right: right)
          pos = new-pos
        } else {
          break
        }
      }

      (left, pos)
    },
  )

  let tokens = (tokenizer.tokenize)(tokenizer, expr, ())
  tokens = add-implicit-mult(tokens)
  let (result, _) = (parser.expr)(parser, tokens, 0)
  result
}
