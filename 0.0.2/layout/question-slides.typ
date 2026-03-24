#import "../utilities/repeating.typ": repeating

/**
 * Utility function to lay out questions each on a separate slide
 */
#let question-slides = (title: "Practice Questions", content) => {
  // Separate content into array of enumerate items
  let items = content.children.filter(c => c.has("body"))

  for item in items {
    heading(title, level: 2)
    item
  }
}
