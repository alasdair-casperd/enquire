#import "../utilities/repeating.typ": *
#import "../utilities/to-string.typ": *
#import "../answers/default-answer-settings.typ": default-answer-settings
#import "default-numbering-levels.typ": default-numbering-levels

/**
 * Function to define numbering style and generate numbered labels.
 */
#let define-numbering = (numbering-levels: default-numbering-levels) => {
  // State in which to store the prefix applied to the question label
  let question-label-prefix-state = state("question-label-prefix", "")

  // Function to generate the label for a specified level and value.
  // e.g. Level = 2 and value = 3 might output content displaying 'c)'
  let f = (level, value) => {
    if level > numbering-levels.len() {
      // Default numbering if none is specified for this level
      return numbering("1)", value)
    } else {
      let l = numbering-levels.at(level - 1)

      let output = numbering(l.label, value)

      // For the first level only, add the question label prefix
      if (level == 1) { output = question-label-prefix-state.get() + output }

      if l.weight != none {
        output = text(weight: l.weight, output)
      }

      if l.color != none {
        output = text(fill: l.color, output)
      }

      if l.font != none {
        output = text(font: l.font, output)
      }

      if l.container != none {
        output = (l.container)(output)
      }

      return output
    }
  }

  return (..numbering-arguments) => context {
    let input-numbering = numbering-arguments.pos()

    // Store total question count, e.g. for use in exam papers
    let total-question-count-state = state("total-question-count", 0)

    // Store a counter for each enumeration level (only 1-3 are supported currently)
    let level-1-state = state("level-1-numbering", 0)
    let level-2-state = state("level-2-numbering", 0)
    let level-3-state = state("level-3-numbering", 0)

    let level = input-numbering.len()

    let numbering = ()

    if level == 1 {
      total-question-count-state.update(x => x + 1)
      let n = level-1-state.get() + 1
      numbering = (n,)
      level-1-state.update(x => x + 1)
      level-2-state.update(0)
      level-3-state.update(0)
    } else if level == 2 {
      let n = level-2-state.get() + 1
      numbering = (level-1-state.get(), n)
      level-2-state.update(x => x + 1)
      level-3-state.update(0)
    } else if level == 3 {
      let n = level-3-state.get() + 1
      numbering = (level-1-state.get(), level-2-state.get(), n)
      level-3-state.update(x => x + 1)
    }

    // Generate the appropriate label (e.g. (a))
    let label = f(numbering.len(), numbering.last())

    // Generate the full label (e.g. (1)(a)) for logging
    let full-label = [
      #for i in range(0, numbering.len()) {
        f(i + 1, numbering.at(i))
        []
      }
    ]

    // Store the enum level in state for use elsewhere
    // Hopefully this will be exposed on the enum show rule in a future typst update
    let enum-level = state("enum-level", 0)
    enum-level.update(level)

    // Store the full label in state
    let question-label-state = state("question-label", "Q")
    question-label-state.update(full-label)

    // Display the label
    [#label]
  }
}
