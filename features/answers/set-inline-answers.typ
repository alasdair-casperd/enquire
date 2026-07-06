#import "/features/questioning/_default-inline-formatter.typ": _default-inline-formatter
#import "/features/questioning/_directive.typ": _directive
#import "/features/questioning/_eq-state.typ": _eq-state
#import "/features/questioning/_normalise-inline.typ": _normalise-inline
#import "/features/questioning/_render-label.typ": _render-label

/// Enable, disable or customise inline answer display from this point on.
/// `true`/`auto` uses the default boxed formatter, `none`/`false` disables,
/// a function `body => content` customises the rendering.
#let set-inline-answers(formatter) = _directive(_eq-state.update(s => {
  s.config.inline-answers = _normalise-inline(formatter, _default-inline-formatter)
  s
}))
