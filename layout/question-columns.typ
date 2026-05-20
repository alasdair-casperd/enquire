#import "@preview/itemize:0.2.0"

/**
 * Lays out enum questions in a multi-column grid without breaking
 * the enumerate numbering flow.
 *
 * Parameters:
 * - columns (int, array): Column definitions for the grid.
 *     - `int`   — that many equal-width (`1fr`) columns.
 *     - `array` — passed directly to `grid` (e.g. `(2fr, 1fr)`).
 * - content (content): An enum whose items become the grid cells.
 * - row-gutter (length): Vertical space between rows. Default: `1.5em`.
 * - column-gutter (length): Horizontal space between columns. Default: `1.5em`.
 * - after (length): Trailing space inserted after the grid. Default: `1em`.
 */
#let question-columns = (columns, content, row-gutter: 1.5em, column-gutter: 1.5em, after: 1em) => {
  let items = content.children.filter(c => c.has("body"))

  let first = true
  items = items
    .enumerate()
    .map(((i, item)) => [
      #if i != 0 { itemize.resume() }
      #item
    ])
  if type(columns) == int {
    columns = (1fr,) * columns
  }

  grid(columns: columns, column-gutter: column-gutter, row-gutter: row-gutter, ..items)
  v(after)
}
