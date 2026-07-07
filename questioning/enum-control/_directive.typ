/// Wrap a state update that may be placed between enum items. Typst merges
/// enums separated only by invisible content, and any stray content absorbed
/// by the merge is hoisted out of order — so a bare update between two enums
/// would not apply to the items that follow it. The zero vertical spacing
/// breaks the item grouping without any visible effect (it must not be weak:
/// weak spacing collapses neighbouring weak spacing, e.g. below headings).
#let _directive(update) = {
  v(0pt)
  update
}
