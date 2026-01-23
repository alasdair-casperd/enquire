#import "default-answer-settings.typ": default-answer-settings

#let configure-answers = (
  priority: -1,
  display: true,
  inline: false,
  heading-levels: (2, 3),
) => {
  context {
    let answer-settings-state = state("answer-settings", default-answer-settings)
    let current-settings = answer-settings-state.get()
    let new-settings = current-settings

    if priority >= current-settings.display.priority {
      new-settings = new-settings.set("display", display)
    }
    if priority >= current-settings.inline.priority {
      new-settings = new-settings.set("inline", inline)
    }
    if priority >= current-settings.heading-levels.priority {
      new-settings = new-settings.set("heading-levels", heading-levels)
    }
    answer-settings-state.update(new-settings)
  }
}
