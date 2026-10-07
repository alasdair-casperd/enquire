#import "/questioning/answers/_answer-key.typ": _answer-key
#import "/questioning/enum-control/_eq-state.typ": _eq-state

/// Record mark scheme notes against the current enum item, to be shown later
/// by `display-mark-scheme`. Must be called inside an enum item. Nothing is
/// rendered at the call site.
///
/// Named arguments are named properties: one per question part. Unnamed
/// arguments are basic properties: `display-mark-scheme` deals them out in
/// order across the integer entries of its `mapping`, one table row per
/// cycle. Calling it again in the same item adds to what is already recorded.
///
/// ```typst
/// + Is Devnaa correct? Explain your answer.
///   #mark-scheme(
///     typical-solution: [Devnaa is not correct.],
///     [B1], [Devnaa is *not* correct],
///     [R1], [States that both 1 and -13 could fill the blank],
///   )
/// ```
#let mark-scheme(..args) = {
  let call = (named: args.named(), basic: args.pos())
  _eq-state.update(s => {
    assert(
      s.path.len() > 0,
      message: "#mark-scheme must be called inside an enum item (after `#show: enum-setup`).",
    )
    let key = _answer-key(s)
    let entry = s.mark-scheme.at(key, default: (
      numbers: s.path,
      epoch: s.epoch,
      data: s.data,
      calls: (),
    ))
    if call not in entry.calls { entry.calls.push(call) }
    s.mark-scheme.insert(key, entry)
    s
  })
}
