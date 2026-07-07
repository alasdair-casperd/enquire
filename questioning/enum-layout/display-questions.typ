#import "_extract-items.typ": _extract-items

/// Lay out enum questions according to a custom display function. Questions are extracted from the
/// content and split into an array passed to the display function. State-driven numbering continues
/// across cells automatically.
///
/// Parameters:
/// - display-function (function): Function that handles the layout of the questions once split.
#let display-questions(
  display-function,
  content,
) = {
  let items = _extract-items(content)
  if type(columns) == int { columns = (1fr,) * columns }
  display-function(items)
}
