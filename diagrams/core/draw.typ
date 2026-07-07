#import "@preview/cetz:0.4.2"

///
/// Draw a line through the given points. Wrapper around Cetz's `line` that
/// also records the points in the canvas' shared data so that later elements
/// (such as `side`) can position themselves sensibly relative to the figure
/// drawn so far.
///
#let draw = (
  ..pts-style,
  close: false,
  name: none,
) => {
  let pts = pts-style.pos()

  // Record the drawn points for use by other elements
  cetz.draw.set-ctx(ctx => {
    let shared-data = ctx.at("shared-data", default: (:))
    shared-data.insert("points", shared-data.at("points", default: ()) + pts)
    ctx.insert("shared-data", shared-data)
    return ctx
  })

  cetz.draw.line(..pts-style, close: close, name: name)
}
