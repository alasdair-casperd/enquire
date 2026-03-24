/**
 * Utility function to determine whether or not there are answers to show.
 */
#let document-contains-answers = () => {
  let answer-list = state("answer-list", ()).get()
  return not answer-list in (none, ())
}
