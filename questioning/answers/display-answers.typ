#import "/questioning/enum-control/_default-inline-formatter.typ": _default-inline-formatter
#import "/questioning/enum-control/_directive.typ": _directive
#import "/questioning/enum-control/_eq-state.typ": _eq-state
#import "/questioning/enum-control/_normalise-inline.typ": _normalise-inline
#import "/questioning/enum-control/_render-label.typ": _render-label
#import "clear-answers.typ": clear-answers

/// Display all answers recorded so far as a compact grid. Labels are shown
/// with a sensible hierarchy: each row only repeats the label levels that
/// changed since the previous answer, e.g.
///
/// ```
/// 1. 6
/// 2. a. 24
///    b. i.   -1
///       iii. 18
/// ```
///
/// Items without answers are skipped. Labels are rendered with the current
/// label-format / label-style and the enum data recorded with each answer.
///
/// Parameters:
/// - clear (bool): Forget the displayed answers afterwards, so a later
///   `display-answers()` only shows subsequent sections. Default: `true`.
/// - full-labels (bool): Show the full label chain on every row instead of
///   the hierarchical display. Default: `false`.
/// - sep (content): Separator between multiple answers to one item.
/// - row-gutter, column-gutter (length): Grid spacing.
#let display-answers(
  clear: true,
  full-labels: false,
  sep: [, ],
  row-gutter: 0.65em,
  column-gutter: 0.5em,
) = {
  context {
    let s = _eq-state.get()
    let entries = s.answers.values().sorted(key: e => (e.epoch,) + e.numbers)
    if entries.len() > 0 {
      let max-depth = calc.max(..entries.map(e => e.numbers.len()))
      let cells = ()
      let previous = none
      for entry in entries {
        let numbers = entry.numbers
        // First level at which this entry's path diverges from the previous
        // one; label cells before it are left blank.
        let diverge = 0
        if not full-labels and previous != none and previous.epoch == entry.epoch {
          let shared = calc.min(previous.numbers.len(), numbers.len())
          while diverge < shared and previous.numbers.at(diverge) == numbers.at(diverge) {
            diverge += 1
          }
          // A parent that also has an answer shares its child's full path
          // prefix; still show the child's last label.
          diverge = calc.min(diverge, numbers.len() - 1)
        }
        for k in range(numbers.len()) {
          cells.push(
            if k < diverge [] else {
              _render-label(s.config, entry.data, numbers.slice(0, k + 1))
            },
          )
        }
        cells.push(grid.cell(
          colspan: max-depth - numbers.len() + 1,
          entry.answers.join(sep),
        ))
        previous = entry
      }
      grid(
        columns: max-depth + 1,
        column-gutter: column-gutter,
        row-gutter: row-gutter,
        align: left,
        ..cells,
      )
    }
  }
  if clear { clear-answers() }
}
