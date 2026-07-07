/// Normalise the `inline-answers` option: `none`/`false` disables inline
/// display, `true`/`auto` uses the default formatter, a function is used
/// directly.
#let _normalise-inline(value, default-formatter) = {
  if value in (none, false) { none } else if value in (true, auto) { default-formatter } else { value }
}
