#import "default-answer-settings.typ": default-answer-settings

#let configure-answers = (
  priority: 1,
  display: true,
  inline: false,
  heading-levels: (2, 3),
) => {
  context {
    let answer-settings-state = state("answer-settings", default-answer-settings)
    let current-settings = answer-settings-state.get()
    let new-settings = current-settings

    if priority >= current-settings.display.priority {
      new-settings.insert("display", (value: display, priority: priority))
    }
    if priority >= current-settings.inline.priority {
      new-settings.insert("inline", (value: inline, priority: priority))
    }
    if priority >= current-settings.heading-levels.priority {
      new-settings.insert("heading-levels", (value: heading-levels, priority: priority))
    }
    answer-settings-state.update(new-settings)
  }
}
