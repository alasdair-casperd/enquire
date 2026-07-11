#let generate-numbering = numbering

///
/// Function to display multiple choice options.
///
#let multiple-choice = (
  ..options,
  grid-parameters: (:),
  align: left,
  columns: none,
  column-gutter: 2em,
  row-gutter: 2em,
  numbering: "A",
  label-formatter: strong,
  label-spacing: 1em,
  colspans: (),
) => {
  // Default to equal with columns
  if columns == none {
    columns = (1fr,) * options.pos().len()
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
      if numbering != none {
        label = generate-numbering(numbering, i + 1)
        label = label-formatter(label)
      }

      grid.cell(colspan: colspan, align: align, {
        if label != none {
          label
          h(label-spacing)
        }
        option
      })
    })

  grid(
    columns: columns,
    align: center,
    column-gutter: column-gutter,
    row-gutter: row-gutter,
    ..grid-parameters,
    ..cells
  )
}
