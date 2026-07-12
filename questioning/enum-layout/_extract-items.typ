/// Collect the enum items contained in `content`, which may be an enum, a
/// bare item, or markup containing any mix of them.
#let _extract-items(content) = {
  if content.func() == enum {
    content.children
  } else if content.func() == enum.item {
    (content,)
  } else if content.has("children") {
    content.children.map(_extract-items).join(default: ())
  } else {
    ()
  }
}
