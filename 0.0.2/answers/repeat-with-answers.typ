#import "default-answer-settings.typ": default-answer-settings
#import "configure-answers.typ": configure-answers
/**
 * Function to repeat piece of content, showing inline answers on the repeat.
 */
#let repeat-with-answers = body => {
  context {
    // Access answer settings state
    let answer-settings = state("answer-settings", default-answer-settings).get()
    let inline-answers = answer-settings.at("inline")
    let display-answers = answer-settings.at("display")

    if (inline-answers.value) [True] else [False]

    body

    // Show again with answers
    configure-answers(
      priority: inline-answers.priority,
      inline: true,
      display: true,
    )
    body

    // Restore original settings
    // TODO: This adds settings to other properties unintentionally and doesn't properly respect priority
    configure-answers(
      priority: inline-answers.priority,
      inline: inline-answers.value,
      display: display-answers.value,
    )
  }
}

