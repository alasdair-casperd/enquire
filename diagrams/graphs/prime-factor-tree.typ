#import "@preview/tdtr:0.6.0": binary-tree-graph, tree-graph-wrapper

///
/// Utility function to access metadata within a node.
///
#let _node-metadata(label) = {
  if type(label) != content { return () }
  if not label.has("children") {
    if label.func() == metadata { (label.value,) } else { () }
  } else {
    label.children.fold((), (acc, c) => acc + _node-metadata(c))
  }
}

///
/// Function to draw a prime factor tree. Leaves are automatically circled. Wraps the `tdtr` package.
///
#let prime-factor-tree = tree-graph-wrapper(
  tree-graph-fn: binary-tree-graph,
  draw-node: (
    // hide every node's outline (the circle shape is kept for consistent sizing)
    (stroke: none),
    // fill any node tagged with `#bg(...)`
    ((name, label, pos)) => {
      let cs = _node-metadata(label).filter(m => type(m) == dictionary and "tdtr-bg" in m)
      if cs.len() > 0 { (fill: cs.last().tdtr-bg) } else { (:) }
    },
  ),
  // then draw a visible circle only around the leaves
  additional-draw: (nodes, (node, edge)) => {
    let flat-index(x) = nodes
      .filter(y => (
        y.pos.i == x.pos.i
          and (
            y.pos.j < x.pos.j or (y.pos.j == x.pos.j and y.pos.k < x.pos.k)
          )
      ))
      .len()
    let is-leaf(x) = {
      let n = flat-index(x)
      not nodes.any(z => z.pos.i == x.pos.i + 1 and z.pos.j == n)
    }
    nodes
      .filter(is-leaf)
      .map(x => node(
        (x.pos.x, x.pos.y),
        text(fill: rgb("#00000000"))[#x.label],
        shape: circle,
        stroke: .5pt,
        width: 1.6em,
      ))
  },
)
