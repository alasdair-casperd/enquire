/**
 * Utility function to intersperse a separator between the elements of an array.
 */
#let intersperse(arr, sep) = {
  if arr.len() <= 1 { return arr }
  arr.slice(1).fold((arr.first(),), (acc, x) => acc + (sep, x))
}
