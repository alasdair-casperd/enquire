# Changelog

## [0.0.7] - 2026-11-06

### Diagrams

#### Core

- The default canvas alignment is now `center`
- Added automatic anchor selection to nodes, e.g. with `node(A, $A$)`

#### Plotting

- Added support for plotting modulus functions
- Fixed issue where axes would not render correctly if supplied with non-integer bounds
- Added additional ways to defined the bounds in the `axes` function (`x-min`, `x-max`, `y-min`, `y-max`, `x-range` and `y-range`)

#### Patterns

- Added a new cross-hatch pattern

#### Utilities

- Added `line-points` utility to give two points on a line from its equation (the reverse of `line-equation`)

### Questioning

#### Mark Scheme

- Added `mark-scheme` and related functions (`get-mark-scheme`, `display-mark-scheme`, `clear-mark-scheme`) for defining and displaying a mark scheme

#### Marks

- Fixed issues with marks formatter removing any specified liens
- Added `counted` parameter to the `marks` function to allow marks to be displayed without these contributing to counted totals
- Added `end-of-questions` component to mark the end of assessed questions in a paper and turn off question and mark counting

#### Lines

- Added `answer-line` component to display an answer line

#### Enum Layout

- Fixed alignment issue where the first child of an enum item was a canvas

## [0.0.6] - 2026-07-13

### Diagrams

#### Graphs

- Added prime factor tree function to diagrams

### Other

- Removed module unpacking from `lib.typ`

## [0.0.5] - 2026-07-12

- Absorbed features from `answerly` and `geometry` packages
- Added ability for `display-answers` to output answers as a nested list rather than outputting the full enum label for each answer
- Fixed layout convergence issues with `#ans` and resuming numbering
