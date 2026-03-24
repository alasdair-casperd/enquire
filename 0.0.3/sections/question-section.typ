#import "../utilities/to-string.typ": to-string
#import "../numbering/reset-numbering.typ": reset-numbering

/**
 * Function to add a prefix to questions in a section, and optionally reset the numbering
 */
#let question-section = (heading-content: none, prefix: none, reset: false) => {
  if not heading-content == none {
    // Configure heading function to record headings against the list of answers
    show heading: it => {
      let answer-list = state("answer-list", ())
      answer-list.update(x => x + ((type: "heading", level: it.level, content: it.body),))
      it
    }

    // Display the heading
    heading-content
  }


  context {
    let question-label-prefix-state = state("question-label-prefix", [])
    let section-question-numbering-state = state("section-question-numbering", (:))
    let level-1-state = state("level-1-numbering", 0)

    let current-prefix = question-label-prefix-state.get()
    let current-level-1-number = level-1-state.get()
    let current-section-question-numbering-state = section-question-numbering-state.get()

    section-question-numbering-state.update(x => {
      let key = "key_" + to-string(current-prefix)
      x.insert(key, current-level-1-number)
      return x
    })

    question-label-prefix-state.update(x => prefix)

    if not reset and "key_" + to-string(prefix) in current-section-question-numbering-state {
      // panic("test")
      let target-level-1-number = section-question-numbering-state.get().at("key_" + to-string(prefix))
      reset-numbering(to: target-level-1-number)
    } else {
      reset-numbering()
    }
  }
}

// Question section aliases

#let section = (heading, reset: false) => question-section(
  heading-content: heading,
  prefix: none,
  reset: reset,
)

#let prefix = (prefix, reset: false) => question-section(
  heading-content: none,
  prefix: prefix,
  reset: reset,
)

#let prefix-section = (prefix, heading, reset: false) => question-section(
  heading-content: heading,
  prefix: prefix,
  reset: reset,
)
