/*
  Core setup and styling for all documents.
*/
#let core-styling(doc) = {
  //
  // Configure language and region for spellchecking in the web app
  //

  set text(lang: "en", region: "gb")

  //
  // Style stroke for line, rect, table and grid
  //

  let stroke = rgb(0, 0, 0, 50) + 0.5pt

  set line(stroke: stroke, length: 100%)
  set rect(stroke: stroke, inset: 16pt)

  set table(stroke: stroke, inset: 4pt)
  set table.hline(stroke: stroke)
  set table.vline(stroke: stroke)

  set grid.hline(stroke: stroke)
  set grid.vline(stroke: stroke)

  //
  // Maths mode overrides
  //

  // Change cosecant format in math mode
  show math.equation: it => {
    show "csc": "cosec"
    it
  }

  doc
}
