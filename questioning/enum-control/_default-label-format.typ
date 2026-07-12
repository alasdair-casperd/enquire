/// Default label format: render the current level's number with the
/// configured per-level pattern, prepending the prefix at level 1.
#let _default-label-format(patterns, info) = {
  let pattern = patterns.at(calc.min(info.level, patterns.len()) - 1)
  let number = std.numbering(pattern, info.number)
  if info.level == 1 and info.prefix != none [#info.prefix#number] else [#number]
}
