#import "configure-marks.typ": configure-marks
#import "../enum-control/_directive.typ": _directive
#import "../enum-control/_eq-state.typ": _eq-state

///
/// Turns off question counting and mark counting.
/// This could be used, for example, before bonus questions at the end of a test to prevent these contributing to mark and question totals.
///
/// Wrapped in `_directive` so the updates stay in order when placed between
/// enum items.
///
#let end-of-questions = () => _directive({
  configure-marks(counted: false)
  _eq-state.update(s => {
    s.counted = false
    s
  })
})
