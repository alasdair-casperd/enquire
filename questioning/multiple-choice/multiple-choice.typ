#import "_multiple-choice-state.typ": *
#import "../../utilities/_css.typ": length-to-css, columns-to-css, align-to-css, align-to-flex-css

#let generate-numbering = numbering

// Fall back to paged output on compilers without HTML support
#let target-or-paged = if "target" in dictionary(std) { std.target } else { () => "paged" }

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

    let entries = options
      .pos()
      .enumerate()
      .map(x => {
        let i = x.at(0)
        let option = x.at(1)

        let label = none

        // Add a label
        if effective-numbering != none {
          label = generate-numbering(effective-numbering, i + 1)
          label = effective-label-formatter(label)
        }

        (option: option, label: label, colspan: colspans.at(i, default: 1))
      })

    if target-or-paged() == "html" {
      // Replicate the grid layout with CSS grid; grid-parameters only applies to paged output
      let container-styles = ("display: grid", "grid-template-columns: " + columns-to-css(effective-columns))
      if type(effective-column-gutter) == length {
        container-styles.push("column-gap: " + length-to-css(effective-column-gutter))
      }
      if type(effective-row-gutter) == length {
        container-styles.push("row-gap: " + length-to-css(effective-row-gutter))
      }

      let cells = entries.map(entry => {
        // Lay out each cell as a flex row so that labels always sit to the
        // left of their options, even when the option is block content
        let styles = ("display: flex",)
        styles += align-to-css(effective-align)
        styles += align-to-flex-css(effective-align)
        if entry.colspan > 1 {
          styles.push("grid-column: span " + str(entry.colspan))
        }

        html.elem("div", attrs: (style: styles.join("; ")), {
          if entry.label != none {
            html.elem(
              "span",
              attrs: (style: "margin-right: " + length-to-css(effective-label-spacing)),
              entry.label,
            )
          }
          entry.option
        })
      })

      html.elem("div", attrs: (style: container-styles.join("; ")), cells.join())
    } else {
      let cells = entries.map(entry => {
        grid.cell(colspan: entry.colspan, align: effective-align, {
          if entry.label != none {
            // A nested grid keeps the label to the left of the option, even
            // when the option is block content
            grid(
              columns: 2,
              column-gutter: effective-label-spacing,
              entry.label,
              entry.option,
            )
          } else {
            entry.option
          }
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
}
