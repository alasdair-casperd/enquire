
/**
 * Utility function to convert a variable which may be content to a string.
 */
#let to-string(it) = {
  if it == none {
    "NONE"
  } else if type(it) == str {
    it
  } else if type(it) != content {
    str(it)
  } else if it.has("text") {
    it.text
  } else if it.has("children") {
    it.children.map(to-string).join()
  } else if it.has("body") {
    to-string(it.body)
  } else if it == [ ] {
    " "
  }
}
