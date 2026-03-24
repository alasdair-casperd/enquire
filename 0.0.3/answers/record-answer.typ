#import "default-answer-settings.typ": default-answer-settings

/**
 * Function to record answers and optionally display them.
 */
#let record-answer = (custom-label: none, content) => {
  context {
    // Access answer settings to determine whether inline answers should be shown
    let answer-settings-state = state("answer-settings", default-answer-settings).get()
    let inline-answers = answer-settings-state.at("inline").value
    let display-answers = answer-settings-state.at("display").value
    let display = display-answers and inline-answers

    // Handle inline display
    if (display) {
      rect(inset: 6pt, radius: 4pt, width: auto, fill: rgb(20, 150, 120, 20), stroke: none, text(
        fill: rgb(15, 35, 20),
        content,
      ))
    }

    // Retrieve the current question label or use the custom one provided
    let question-label = custom-label
    if question-label == none {
      question-label = state("question-label", "Q").get()
    }

    // Record the answer in state
    let answer-list = state("answer-list", ())
    answer-list.update(x => x + ((type: "answer", label: question-label, content: content),))
  }
}
