/**
 * Renders each enum question on its own slide with a repeated heading.
 *
 * Parameters:
 * - title (str): Heading text shown above each question. Default: `"Practice Questions"`.
 * - content (content): An enum whose items are rendered as individual slides.
 */
#let question-slides = (title: "Practice Questions", content) => {
  let items = content.children.filter(c => c.has("body"))

  for item in items {
    heading(title, level: 2)
    item
  }
}
