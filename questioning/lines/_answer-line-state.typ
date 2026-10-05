#let _answer-line-length = state("answer-line-length", "medium")
#let _answer-line-element = state("answer-line-element", line.with(length: 100%))
#let _answer-line-wrapper = state("answer-line-wrapper", x => x)
#let _answer-line-align = state("answer-line-align", right)
#let _answer-line-display = state("answer-line-display", true)
#let _answer-line-gap = state("answer-line-gap", 0.3em)
// Widths for the named lengths accepted by `answer-line`
#let _answer-line-lengths = state("answer-line-lengths", (short: 4em, medium: 8em, long: 15em))
