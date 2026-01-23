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


/**
 * Function to display repeated lines.
 */
#let lines = n => {
  context {
    if not determine-lines-visibility() { return }

    v(1em)

    for _ in range(1, n + 1) {
      line()
      v(1em)
    }

    v(0.3em)
  }
}

/**
 * Function to fill available space with lines.
 */
#let fill-lines = () => {
  context {
    // Access answer display state
    if not determine-lines-visibility() { return }

    block(height: 1fr, width: 100%, clip: true)[
      #repeat[
        #lines(100)
      ]
    ]
    pagebreak()
  }
}

