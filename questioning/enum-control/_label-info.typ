/// Build the info dictionary passed to label-format / label-style.
#let _label-info(data, numbers) = (
  number: numbers.last(),
  numbers: numbers,
  level: numbers.len(),
  prefix: data.at("prefix", default: none),
  data: data,
)
