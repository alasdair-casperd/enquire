/**
 * Function to reset enumerate counter.
 */
#let reset-numbering = (to: 0) => {
  context {
    let level-1-state = state("level-1-numbering", 0)
    let level-2-state = state("level-2-numbering", 0)
    let level-3-state = state("level-3-numbering", 0)

    level-1-state.update(to)
    level-2-state.update(0)
    level-2-state.update(0)
  }
}
