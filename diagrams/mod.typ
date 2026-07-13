// The diagrams module: tools for creating diagrams and graphs for secondary
// school mathematics (originally published as the standalone `geometry`
// package).
//
// Everything is built on top of Cetz. The Cetz namespace itself is
// re-exported so that documents can drop down to raw Cetz drawing where
// needed.

#import "@preview/cetz:0.4.2"
#import "@preview/cetz-venn:0.1.4": venn2, venn3

// Direct Cetz re-exports
#import cetz.draw: circle as draw-circle, set-style

// Core drawing elements
#import "core/mod.typ": *

// Angle marking
#import "angles/mod.typ": *

// Plotting
#import "plotting/mod.typ": *

// Shape transformations, namespaced to avoid clashing with Typst's own
// `rotate`, `scale` etc. (use as `transform.rotate`, `transform.reflect`, ...)
#import "transformations/mod.typ" as transform

// Fill patterns for shaded regions
#import "patterns/mod.typ": patterns

// Geometric utilities (midpoints, intersections, polar coordinates, and the
// `vector` namespace of vector maths)
#import "utilities/mod.typ": *

// Parsing and evaluation of mathematical expressions (used internally by
// `plot`; exported for direct use)
#import "parsing/mod.typ": *

// Functions for drawing graphs (in the graph theoretical sense, see `plotting` for graphs of equations)
#import "graphs/mod.typ": *
