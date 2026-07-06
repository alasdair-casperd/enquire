#import "/features/questioning/_default-inline-formatter.typ": _default-inline-formatter
#import "/features/questioning/_directive.typ": _directive
#import "/features/questioning/_eq-state.typ": _eq-state
#import "/features/questioning/_normalise-inline.typ": _normalise-inline
#import "/features/questioning/_render-label.typ": _render-label
#import "_answer-key.typ": _answer-key

/// Record an answer against the current enum item. Must be called inside an
/// enum item. If inline answers are enabled (see `setup` /
/// `set-inline-answers`), the answer is also rendered at the call site.
///
/// ```typst
/// + Solve $x^2 = 4$. #ans[$x = plus.minus 2$]
/// ```
#let ans(body) = {
  _eq-state.update(s => {
    assert(
      s.path.len() > 0,
      message: "#ans must be called inside an enum item (after `#show: setup`).",
    )
    let key = _answer-key(s)
    let entry = s.answers.at(key, default: (
      numbers: s.path,
      epoch: s.epoch,
      data: s.data,
      answers: (),
    ))
    if body not in entry.answers { entry.answers.push(body) }
    s.answers.insert(key, entry)
    s
  })
  context {
    let formatter = _eq-state.get().config.inline-answers
    if formatter != none { formatter(body) }
  }
}
