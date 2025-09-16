#import "base.typ": *

#let software-dev(
  area: none,
) = [
  #assert_set(area, "area must be set")
  #template(
    statement: [Ambitious and hard working graduate with a passion for #area.
      Received a first-class honours in computer science at
      Northumbria University. Currently awaiting results for my master’s degree in
      game engineering at Newcastle University, achieving grades of 95% or higher in all
      assignments. Skilled in multiple programming languages and paradigms
      such as object-oriented, procedural, and event-driven.
    ],
    tech_links: true,
  )
]
