
/**
 * Utility function to create an array by repeating an element a specified number of times.
 */
#let repeating(element, count) = {
  let output = ()

  for i in range(0, count) {
    output.push(element)
  }

  return output
}