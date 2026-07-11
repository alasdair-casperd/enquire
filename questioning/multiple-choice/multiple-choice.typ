#import "_multiple-choice-state.typ": *

#let generate-numbering = numbering

///
/// Function to display multiple choice options.
///
#let multiple-choice = (
  ..options,
  grid-parameters: none,
  align: none,
  columns: none,
  column-gutter: none,
  row-gutter: none,
  numbering: auto,
  label-formatter: none,
  label-spacing: none,
  colspans: (),
) => {
  context {
    let effective-grid-parameters = if grid-parameters != none { grid-parameters } else {
      _multiple-choice-grid-parameters.get()
    }
    let effective-align = if align != none { align } else { _multiple-choice-align.get() }
    let effective-columns = if columns != none { columns } else { _multiple-choice-columns.get() }
    let effective-column-gutter = if column-gutter != none { column-gutter } else {
      _multiple-choice-column-gutter.get()
    }
    let effective-row-gutter = if row-gutter != none { row-gutter } else { _multiple-choice-row-gutter.get() }
    let effective-numbering = if numbering != auto { numbering } else { _multiple-choice-numbering.get() }
    let effective-label-formatter = if label-formatter != none { label-formatter } else {
      _multiple-choice-label-formatter.get()
    }
    let effective-label-spacing = if label-spacing != none { label-spacing } else {
      _multiple-choice-label-spacing.get()
    }

    // Default to equal width columns
    if effective-columns == auto {
      effective-columns = (1fr,) * options.pos().len()
    }

    let cells = options
      .pos()
      .enumerate()
      .map(x => {
        let i = x.at(0)
        let option = x.at(1)

        // Select the appropriate colspan
        let colspan = colspans.at(i, default: 1)

        let label = none

        // Add a label
        if effective-numbering != none {
          label = generate-numbering(effective-numbering, i + 1)
          label = effective-label-formatter(label)
        }

        grid.cell(colspan: colspan, align: effective-align, {
          if label != none {
            label
            h(effective-label-spacing)
          }
          option
        })
      })

    grid(
      columns: effective-columns,
      align: center,
      column-gutter: effective-column-gutter,
      row-gutter: effective-row-gutter,
      ..effective-grid-parameters,
      ..cells
    )
  }
}
