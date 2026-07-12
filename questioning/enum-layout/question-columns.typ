#import "display-questions.typ": display-questions

/// Lay out enum questions in a multi-column grid (left to right, then top
/// to bottom) without breaking the numbering flow: each item becomes its own
/// single-item enum, and the state-driven numbering continues across cells
/// automatically.
///
/// ```typst
/// #question-columns(3)[
///   + $1 + 1$
///   + $2 + 2$
///   + $3 + 3$
/// ]
/// ```
///
/// Parameters:
/// - columns (int, array): Column definitions for the grid.
///     - `int`   — that many equal-width (`1fr`) columns.
///     - `array` — passed directly to `grid` (e.g. `(2fr, 1fr)`).
/// - content (content): An enum whose items become the grid cells.
/// - row-gutter (length): Vertical space between rows. Default: `1.5em`.
/// - column-gutter (length): Horizontal space between columns. Default: `1.5em`.
/// - after (length): Trailing space inserted after the grid. Default: `1em`.
#let question-columns(
  columns,
  content,
  row-gutter: 1.5em,
  column-gutter: 1.5em,
  after: 1em,
) = {
  if type(columns) == int { columns = (1fr,) * columns }
  display-questions(
    items => grid(
      columns: columns,
      column-gutter: column-gutter,
      row-gutter: row-gutter,
      // Each cell holds a bare enum.item, realised as its own single-item enum
      // at layout. Constructing `enum(item)` here would break touying, whose
      // mark traversal cannot enter an already-constructed enum element.
      ..items,
    ),
    content,
  )
  v(after)
}
