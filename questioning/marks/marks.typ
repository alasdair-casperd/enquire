#import "_marks-state.typ": *
#import "../lines/mod.typ": lines as lines-function

///
/// Displays a right-aligned mark indicator for a question.
///
#let marks = (n, lines: 0, style: none, weight: none, formatter: none, inline: none) => {
  context {
    let effective-formatter = if formatter != none { formatter } else { _marks-formatter.get() }

    if effective-formatter != none {
      effective-formatter(n)
      [#lines-function(lines)]
    } else {
      let effective-inline = if inline != none { inline } else { _marks-inline.get() }
      let effective-style = if style != none { style } else { _marks-style.get() }
      let effective-weight = if weight != none { weight } else { _marks-weight.get() }

      let marks-string = effective-style
      marks-string = marks-string.replace(regex("\d+"), str(n))
      marks-string = marks-string.replace("(s)", if n == 1 { "" } else { "s" })

      if effective-inline {
        // box(width: 1fr) is a single unbreakable inline element — it can't be
        // separated from its align(right) by the line-breaker, so marks are
        // always right-aligned whether they fit on the current line or wrap.
        // The inner box() prevents the marks text from being broken mid-phrase.
        box(width: 1fr, align(right, box(text(marks-string, weight: effective-weight))))
        if (type(lines) != int or lines > 0) { v(-0.7em) }
        [#lines-function(lines)]
      } else {
        v(-0.3em)
        box(width: 100%, align(right, text(marks-string, weight: effective-weight)))
        if (type(lines) != int or lines > 0) { v(-0.7em) }
        [#lines-function(lines)]
      }
    }

    let total-marks = state("total-marks", 0)
    total-marks.update(t => t + n)
  }
}
