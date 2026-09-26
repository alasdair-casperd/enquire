#import "@preview/cetz:0.4.2"

///
/// Draw a line through the given points. Wrapper around Cetz's `line` that
/// also records the points and segments in the canvas' shared data so that
/// later elements (such as `side` and `node`) can position themselves
/// sensibly relative to the figure drawn so far.
///
#let draw = (
  ..pts-style,
  close: false,
  name: none,
) => {
  let pts = pts-style.pos()

  // Record the drawn points and segments for use by other elements
  cetz.draw.set-ctx(ctx => {
    // Resolve to plain (x, y) pairs so named or relative coordinates can be
    // compared later
    let (_, ..resolved) = cetz.coordinate.resolve(ctx, ..pts, update: false)
    let resolved = resolved.map(p => p.slice(0, 2))

    let segments = range(resolved.len() - 1).map(i => (resolved.at(i), resolved.at(i + 1)))
    if close and resolved.len() > 2 {
      segments.push((resolved.last(), resolved.first()))
    }

    let shared-data = ctx.at("shared-data", default: (:))
    shared-data.insert("points", shared-data.at("points", default: ()) + resolved)
    shared-data.insert("segments", shared-data.at("segments", default: ()) + segments)
    ctx.insert("shared-data", shared-data)
    return ctx
  })

  cetz.draw.line(..pts-style, close: close, name: name)
}
