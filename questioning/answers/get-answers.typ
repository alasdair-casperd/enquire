#import "/questioning/enum-control/_default-inline-formatter.typ": _default-inline-formatter
#import "/questioning/enum-control/_directive.typ": _directive
#import "/questioning/enum-control/_eq-state.typ": _eq-state
#import "/questioning/enum-control/_normalise-inline.typ": _normalise-inline
#import "/questioning/enum-control/_render-label.typ": _render-label

/// All answers recorded so far, in question order. Must be called inside a
/// `context` block. Each entry is a dictionary with keys `numbers` (array),
/// `epoch` (int), `data` (dictionary, including any prefix) and `answers`
/// (array of content).
#let get-answers() = {
  _eq-state.get().answers.values().sorted(key: e => (e.epoch,) + e.numbers)
}
