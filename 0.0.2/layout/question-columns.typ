#import "../utilities/repeating.typ": repeating

/**
 * Utility function to lay out questions in a grid without breaking enumerate flow.
 */
#let question-columns = (columns, content, row-gutter: 1.5em, column-gutter: 1.5em, after: 1em) => {
  // Separate content into array of enumerate items
  let items = content.children.filter(c => c.has("body"))

  // Define columns to use for grid layout
  if type(columns) == int {
    columns = repeating(1fr, columns)
  }

  // Display the questions in a grid
  grid(columns: columns, column-gutter: column-gutter, row-gutter: row-gutter, ..items)

  // Add trailing space after the grid
  v(after)
}
