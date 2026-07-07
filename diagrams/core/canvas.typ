#import "@preview/cetz:0.4.2"

// `align` is shadowed by a parameter of `canvas` below; keep a reference to
// the built-in.
#let alignment = align

///
/// Create a diagram. Wrapper around Cetz's `canvas` that applies the module's
/// default styling and centres the drawing in a full-width box.
///
/// The body may be a function, in which case it is called with the final
/// value of the `current-theme` state, allowing diagrams to adapt to a
/// document theme.
///
/// - body: Cetz draw calls, or a function from a theme to Cetz draw calls
/// - width: width of the box containing the canvas
/// - align: alignment of the canvas within its box
/// - scale: the length of one canvas unit
///
#let canvas = (
  body,
  width: 100%,
  align: center,
  background: none,
  baseline: none,
  debug: false,
  scale: 28.35pt,
  padding: none,
  stroke: none,
) => {
  context {
    box(width: width, height: auto, {
      // Resolve theme-aware bodies
      let theme = state("current-theme").final()
      let resolved-body = if type(body) == function {
        body(theme)
      } else {
        body
      }

      alignment(
        align,
        cetz.canvas(
          background: background,
          baseline: baseline,
          debug: debug,
          length: scale,
          padding: padding,
          stroke: stroke,
          {
            // Default styling for all diagrams
            cetz.draw.set-style(
              stroke: (thickness: 0.07em, cap: "round"),
              content: (padding: 0.4em),
              angle: (radius: 1.2em, label-radius: 2em),
            )

            resolved-body
          },
        ),
      )
    })
  }
}
