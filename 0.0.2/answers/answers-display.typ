#import "default-answer-settings.typ": default-answer-settings

/**
 * Function to display all the answers in a document.
 */
#let answers-display = () => {
  context {
    let answer-settings = state("answer-settings", default-answer-settings).get()

    // Only show the answer display if the answers are displayed and not inline
    let display-answers = answer-settings.at("display").value and not answer-settings.at("inline").value

    if (display-answers) {
      let answer-list = state("answer-list", ()).get()

      if answer-list in (none, ()) { return }

      for list-item in answer-list [
        #if list-item.at("type") == "heading" and list-item.level in answer-settings.at("heading-levels").value [
          #heading(list-item.content, level: list-item.level + 1)
        ]

        #if list-item.at("type") == "answer" [
          #set list(marker: list-item.at("label"))
          - #list-item.at("content") \
        ]
      ]
    }
  }
}
