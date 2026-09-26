#import "@local/enquire:0.0.7": diagrams
#import diagrams: *

#canvas(scale: 1.5cm, {
  let (R, S, T, U) = ((0, 0), (1, 0), (1, 1), (0, 1))
  let P = polar(1, 60deg, center: U)
  let Q = polar(1, -150deg, center: U)
  shape(R, S, T, U)
  draw(T, P, U, Q, R)
  nodes(P, Q, R, S, T, U, labels: ($P$, $Q$, $R$, $S$, $T$, $U$))
})
