#import "_answer-line-state.typ": *

/// Answer line function to display a space for student input.
/// Defaults for every named argument can be set through `configure-answer-line`.
///
/// Positional arguments are laid out left to right. `auto` is replaced by the
/// answer space, a function is called with the answer space, and anything else
/// is shown as given. With no positional arguments a single space is shown.
///
/// - length: a named length ("short", "medium" or "long" by default, see the
///   `lengths` option of `configure-answer-line`) or an exact width for the answer space
/// - element: what fills the answer space (content, or a function returning content)
/// - wrapper: a function applied to the finished answer line
/// - align: `auto` to show the answer line inline, or an alignment to show it
///   on its own line with that alignment
/// - display: whether the answer line is shown at all (false hides it entirely)
/// - gap: spacing between the positional arguments
///
/// Example uses:
///
/// == 1 - A simple space for answers
/// #answer-line(auto)
///
/// == 2 - A simple space for answers with content on either side
/// #answer-line($y=$, auto, [cm])
///
/// == 3 - Space with content just on one side
/// #answer-line(auto, [miles])
///
/// == 4 - Custom space (here, two spaces shown inside a coordinate pair)
/// #answer-line(x => $(#x, #x)$)
///
/// == 5 - Customising the answer space (defaults can be set through state-functions too)
/// #answer-line(length: "short", $x = $, auto) // short, medium or long
/// #answer-line(length: 5.5em, $x = $, auto) // exact length
///
/// == 6 - Other customisable properties (all with state functions too)
///
/// #answer-line(element: repeat([.]), wrapper: x => [Answer in the space below \ #x], align: left, display: true)
#let answer-line = (
  ..parts,
  length: none,
  element: none,
  wrapper: none,
  align: none,
  display: none,
  gap: none,
) => {
  context {
    let effective-length = if length != none { length } else { _answer-line-length.get() }
    let effective-element = if element != none { element } else { _answer-line-element.get() }
    let effective-wrapper = if wrapper != none { wrapper } else { _answer-line-wrapper.get() }
    let effective-align = if align != none { align } else { _answer-line-align.get() }
    let effective-display = if display != none { display } else { _answer-line-display.get() }
    if not effective-display { return }
    let effective-gap = if gap != none { gap } else { _answer-line-gap.get() }

    let width = if type(effective-length) == str {
      let lengths = _answer-line-lengths.get()
      assert(
        effective-length in lengths,
        message: "answer-line: length must be an exact length or one of "
          + lengths.keys().map(repr).join(", ")
          + ", got "
          + repr(effective-length),
      )
      lengths.at(effective-length)
    } else {
      effective-length
    }

    let space = box(
      width: width,
      if type(effective-element) == function { effective-element() } else { effective-element },
    )

    let items = if parts.pos().len() == 0 { (auto,) } else { parts.pos() }
    let body = items
      .map(item => {
        if item == auto { space } else if type(item) == function { item(space) } else { item }
      })
      .join(h(effective-gap))

    // The inner box() keeps the answer line from being broken across lines.
    let result = effective-wrapper(box(body))

    if effective-align == auto {
      result
    } else {
      block(width: 100%, std.align(effective-align, result))
    }
  }
}
