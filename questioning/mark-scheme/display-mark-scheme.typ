#import "/questioning/enum-control/_eq-state.typ": _eq-state
#import "/questioning/enum-control/_render-label.typ": _render-label
#import "clear-mark-scheme.typ": clear-mark-scheme
#import "get-mark-scheme.typ": get-mark-scheme

/// Display all mark scheme notes recorded so far as a table, one block of
/// rows per question part. Parts without notes are skipped. Labels are
/// rendered with the current label-format / label-style and the enum data
/// recorded with each part.
///
/// ```typst
/// #display-mark-scheme(
///   headers: ([Q], [Marking Instructions], [Marks], [Typical Solution]),
///   columns: (auto, 1fr, auto, 1fr),
///   mapping: (auto, 2, 1, "typical-solution"),
/// )
/// ```
///
/// Parameters:
/// - headers (none, array): Header text for each column, shown in bold.
/// - mapping (array): What goes in each column, in order:
///   - `auto`: the full label of the question part, e.g. `5)b)`.
///   - a string: the named property of that name.
///   - an integer: the basic property of that index. The highest integer `n`
///     sets the cycle length: unnamed arguments `1, n + 1, 2n + 1, ...` of
///     `mark-scheme` are basic property 1, and so on, giving one row per
///     cycle. Labels and named properties span all rows of their part.
/// - columns (auto, array): Column widths, e.g. `(auto, 1fr, auto, 1fr)`.
///   `auto` = every column is `auto`.
/// - clear (bool): Forget the displayed notes afterwards, so a later
///   `display-mark-scheme()` only shows subsequent sections. Default: `true`.
/// - ..table-properties: Any other named arguments are passed on to the
///   `table`, e.g. `align: (center, left, center, left)` or `stroke: 0.5pt`.
#let display-mark-scheme(
  headers: none,
  columns: auto,
  mapping: (auto, 1),
  clear: true,
  ..table-properties,
) = {
  assert(
    table-properties.pos().len() == 0,
    message: "display-mark-scheme: unexpected positional argument.",
  )
  assert(
    type(mapping) == array and mapping.len() > 0,
    message: "display-mark-scheme: mapping must be a non-empty array.",
  )
  for m in mapping {
    assert(
      m == auto or type(m) == str or (type(m) == int and m >= 1),
      message: "display-mark-scheme: mapping entries must be auto, a string or a positive integer, found "
        + repr(m)
        + ".",
    )
  }
  assert(
    headers == none or headers.len() == mapping.len(),
    message: "display-mark-scheme: headers and mapping must have the same length.",
  )
  // Number of basic properties per row
  let cycle = calc.max(0, ..mapping.filter(m => type(m) == int))
  context {
    let config = _eq-state.get().config
    let entries = get-mark-scheme()
    if entries.len() > 0 {
      let cells = ()
      for entry in entries {
        let rows = if cycle == 0 { 1 } else {
          calc.max(1, calc.quo(entry.basic.len() + cycle - 1, cycle))
        }
        for row in range(rows) {
          for m in mapping {
            if type(m) == int {
              cells.push(entry.basic.at(row * cycle + m - 1, default: []))
            } else if row == 0 {
              // Spans every row of the part, so only emitted with the first
              cells.push(table.cell(
                rowspan: rows,
                if m == auto {
                  range(entry.numbers.len())
                    .map(k => _render-label(config, entry.data, entry.numbers.slice(0, k + 1)))
                    .join()
                } else {
                  entry.named.at(m, default: [])
                },
              ))
            }
          }
        }
      }
      let properties = (
        (columns: if columns == auto { (auto,) * mapping.len() } else { columns }, align: left)
          + table-properties.named()
      )
      table(
        ..properties,
        ..if headers != none { (table.header(..headers.map(strong)),) },
        ..cells,
      )
    }
  }
  if clear { clear-mark-scheme() }
}
