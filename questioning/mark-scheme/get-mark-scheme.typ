#import "/questioning/enum-control/_eq-state.typ": _eq-state

/// All mark scheme notes recorded so far, in question order. Must be called
/// inside a `context`. Each entry is a dictionary with keys `numbers` (array),
/// `epoch` (int), `data` (dictionary, including any prefix), `named`
/// (dictionary of named properties) and `basic` (array of basic properties).
#let get-mark-scheme() = {
  _eq-state.get().mark-scheme.values().sorted(key: e => (e.epoch,) + e.numbers).map(e => (
    numbers: e.numbers,
    epoch: e.epoch,
    data: e.data,
    named: e.calls.map(c => c.named).join(),
    basic: e.calls.map(c => c.basic).join(),
  ))
}
