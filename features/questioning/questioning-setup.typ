#import "_normalise-inline.typ": _normalise-inline
#import "_default-inline-formatter.typ": _default-inline-formatter
#import "_eq-state.typ": _eq-state
#import "_marker.typ": _marker

/// Configuration show rule. Apply once at the top of the document:
///
/// ```typst
/// #show: questioning-setup
/// // or
/// #show: questioning-setup.with(numbering: ("1)", "a)"), label-style: my-style)
/// ```
///
/// Calling it more than once is safe; the later call's options win from
/// that point on.
///
/// Parameters:
/// - numbering (array): Per-level numbering patterns used by the default
///   label format. Levels deeper than the array reuse the last pattern.
/// - label-format (auto, function): info => content. Formats the label text.
///   `info` is a dictionary with keys `number` (int, count at this level),
///   `numbers` (array, full path), `level` (int, 1-based), `prefix`
///   (content or none) and `data` (dictionary, see `set-enum-data`).
///   `auto` = prepend prefix (level 1 only) to the pattern-rendered number.
/// - label-style (auto, function): (label, info) => content. Visually styles
///   the formatted label. `auto` = no change.
/// - inline-answers (none, bool, auto, function): whether `ans` also renders
///   its answer at the call site, and with what formatter.
#let questioning-setup(
  numbering: ("1.", "a.", "i.", "A.", "I."),
  label-format: auto,
  label-style: auto,
  inline-answers: none,
  body,
) = {
  // Deliberately not wrapped in `_directive`: emitting even invisible layout
  // content here would force a page break if the user writes `#set page`
  // after `#show: setup`. A bare update is safe in this position because the
  // show-rule boundary keeps it ahead of any enum in `body`.
  _eq-state.update(s => {
    s.config = (
      numbering: numbering,
      label-format: label-format,
      label-style: label-style,
      inline-answers: _normalise-inline(inline-answers, _default-inline-formatter),
    )
    s
  })
  set enum(full: true, numbering: _marker)
  body
}
