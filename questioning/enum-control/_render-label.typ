#import "_default-label-format.typ": _default-label-format
#import "_label-info.typ": _label-info

/// Render the label for the item identified by `numbers`, using the given
/// config and enum data. Shared by the enum marker and `display-answers`.
#let _render-label(config, data, numbers) = {
  let info = _label-info(data, numbers)
  let label = if config.label-format == auto {
    _default-label-format(config.numbering, info)
  } else {
    (config.label-format)(info)
  }
  if config.label-style == auto { label } else { (config.label-style)(label, info) }
}
