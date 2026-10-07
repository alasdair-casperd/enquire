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
/// - headers (none, array): Header text for each entry of `mapping`, shown
///   in bold.
/// - header-fill (none, color, ...): Background of the header row.
/// - mapping (array): What goes where, in order:
///   - `auto`: the label of the question part. This takes one table column
///     per label level: for 5)b)ii), the `5)` cell spans every row of
///     question 5, the `b)` cell every row of part b, and `ii)` its own rows.
///     A part with fewer levels than the deepest one has its last label
///     stretched across the spare columns, and the header spans them all.
///   - a string: the named property of that name.
///   - an integer: the basic property of that index. The highest integer `n`
///     sets the cycle length: unnamed arguments `1, n + 1, 2n + 1, ...` of
///     `mark-scheme` are basic property 1, and so on, giving one row per
///     cycle. Labels and named properties span all rows of their part.
/// - columns (auto, array): Width for each entry of `mapping`, e.g.
///   `(auto, 1fr, auto, 1fr)`. The width given for an `auto` entry applies to
///   each of its label columns. `auto` = every column is `auto`.
/// - clear (bool): Forget the displayed notes afterwards, so a later
///   `display-mark-scheme()` only shows subsequent sections. Default: `true`.
/// - ..table-properties: Any other named arguments are passed on to the
///   `table`, e.g. `align: (center, left, center, left)` or `stroke: 0.5pt`.
///   An `align` or `fill` array with one value per entry of `mapping` is
///   stretched over the label columns in the same way as `columns`.
#let display-mark-scheme(
  headers: none,
  header-fill: luma(200),
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
      // Number of label columns each `auto` entry of the mapping takes up
      let depth = calc.max(..entries.map(e => e.numbers.len()))
      // Number of table rows each entry takes up
      let rows = entries.map(e => if cycle == 0 { 1 } else {
        calc.max(1, calc.quo(e.basic.len() + cycle - 1, cycle))
      })
      // Turn one-value-per-mapping-entry into one-value-per-table-column
      let expand(value) = if type(value) == array and value.len() == mapping.len() {
        mapping.zip(value).map(((m, v)) => (v,) * if m == auto { depth } else { 1 }).join()
      } else { value }
      // Whether two entries sit under the same label cell at `level`
      // (0-based). An entry's own last level is never shared.
      let together(a, b, level) = (
        a.epoch == b.epoch
          and a.numbers.len() > level + 1
          and b.numbers.len() > level + 1
          and a.numbers.slice(0, level + 1) == b.numbers.slice(0, level + 1)
      )
      // Label cells starting on the first row of entry `i`. Ancestor labels
      // shared with the previous entry are already covered by its rowspan.
      let label-cells(i) = {
        let entry = entries.at(i)
        let last = entry.numbers.len() - 1
        let cells = ()
        for level in range(last + 1) {
          let label = _render-label(config, entry.data, entry.numbers.slice(0, level + 1))
          if level == last {
            cells.push(table.cell(rowspan: rows.at(i), colspan: depth - last, label))
          } else if i == 0 or not together(entries.at(i - 1), entry, level) {
            let span = 0
            let j = i
            while j < entries.len() and together(entry, entries.at(j), level) {
              span += rows.at(j)
              j += 1
            }
            cells.push(table.cell(rowspan: span, label))
          }
        }
        cells
      }

      let cells = ()
      for (i, entry) in entries.enumerate() {
        for row in range(rows.at(i)) {
          for m in mapping {
            if type(m) == int {
              cells.push(entry.basic.at(row * cycle + m - 1, default: []))
            } else if row == 0 {
              // Spans every row of the part, so only emitted with the first
              if m == auto {
                cells += label-cells(i)
              } else {
                cells.push(table.cell(rowspan: rows.at(i), entry.named.at(m, default: [])))
              }
            }
          }
        }
      }

      let properties = (align: left) + table-properties.named()
      for key in ("align", "fill") {
        if key in properties { properties.insert(key, expand(properties.at(key))) }
      }
      properties.columns = expand(if columns == auto { (auto,) * mapping.len() } else { columns })
      table(
        ..properties,
        ..if headers != none {
          (
            table.header(
              ..headers
                .zip(mapping)
                .map(((h, m)) => table.cell(
                  fill: header-fill,
                  colspan: if m == auto { depth } else { 1 },
                  strong(h),
                )),
            ),
          )
        },
        ..cells,
      )
    }
  }
  if clear { clear-mark-scheme() }
}
