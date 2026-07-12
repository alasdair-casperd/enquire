#import "_multiple-choice-state.typ": *

///
/// Configures default multiple choice display settings, stored in state.
///
#let configure-multiple-choice = (
  grid-parameters: none,
  align: none,
  columns: none,
  column-gutter: none,
  row-gutter: none,
  numbering: auto,
  label-formatter: none,
  label-spacing: none,
) => {
  if grid-parameters != none { _multiple-choice-grid-parameters.update(grid-parameters) }
  if align != none { _multiple-choice-align.update(align) }
  if columns != none { _multiple-choice-columns.update(_ => columns) }
  if column-gutter != none { _multiple-choice-column-gutter.update(column-gutter) }
  if row-gutter != none { _multiple-choice-row-gutter.update(row-gutter) }
  if numbering != auto { _multiple-choice-numbering.update(_ => numbering) }
  if label-formatter != none { _multiple-choice-label-formatter.update(_ => label-formatter) }
  if label-spacing != none { _multiple-choice-label-spacing.update(label-spacing) }
}
