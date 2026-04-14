#let print-lines = (n, spacing: 1em, after: 0.3em, stroke: (:)) => {
  v(spacing)

  for _ in range(1, n + 1) {
    line(stroke: stroke, length: 100%)
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

    print-lines(n, spacing: spacing, after: after, stroke: stroke)
  }
}

