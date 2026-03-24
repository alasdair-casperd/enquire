#import "../answers/default-answer-settings.typ": default-answer-settings

/**
 * Function to decide whether lines should be displayed.
 */
#let determine-lines-visibility = () => {
  // Hide lines when answers are displayed inline
  let answer-settings = state("answer-settings", default-answer-settings).get()
  let display-answers = answer-settings.at("display").value
  let inline-answers = answer-settings.at("inline").value
  return not (display-answers and inline-answers)
}

#let print-lines = (n, spacing: 1em, after: 0.3em, stroke: (:)) => {
  v(spacing)

  for _ in range(1, n + 1) {
    line(stroke: stroke)
    v(spacing)
  }

  v(after)
}

/**
 * Function to display repeated lines.
 */
#let lines = (n, spacing: 1em, after: 0.3em, stroke: (:)) => {
  context {
    if n == auto {
      block(height: 1fr, width: 100%, clip: true)[
        #repeat(
          print-lines(100, spacing: spacing, after: after, stroke: stroke),
        )
      ]
      return
    }
    if not determine-lines-visibility() { return }

    print-lines(n, spacing: spacing, after: after, stroke: stroke)
  }
}

