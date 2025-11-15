// MIT License

// Copyright (c) 2024 Pavel Zwerschke

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Modified by Kieran Knowles 2025. Various layout tweaks
//
// Current changes:
// - 1em spacing above headings
// - add "years experience" to cv-language
// - Display full URL for social media links

#import "@preview/fontawesome:0.5.0": *

#let _cv-line(left, right, above: 1pt, below: 0pt, ..args) = {
  set block(below: below, above: above)
  table(
    columns: (1fr, 5fr),
    stroke: none,
    ..args.named(),
    left,
    right,
  )
}
#let moderncv-blue = rgb("#3973AF")
#let light-gray = rgb("#737373")

#let _header(
  title: [],
  subtitle: [],
  image: none,
  image-frame-stroke: auto,
  colour: moderncv-blue,
  subtitle-colour: light-gray,
  socials-colour: light-gray,
  emphasise: false,
  socials: (:),
) = {
  let subtitle-emphasis = "normal"
  if emphasise {
    subtitle-emphasis = "italic"
  }

  let titleStack = stack(
    dir: ttb,
    spacing: 1em,
    text(size: 30pt, title),
    text(size: 20pt, subtitle, style: subtitle-emphasis, fill: subtitle-colour),
  )

  let social(icon, link_prefix, username) = [
    #let link_text = if link_prefix.starts-with("https://") {
      link_prefix.replace("https://", "")
    } else { "" }
    #if emphasise [
      #emph[#text(socials-colour)[#fa-icon(icon) #link(
          link_prefix + username,
        )[#link_text#username]]]
    ] else [
      #text(socials-colour)[#fa-icon(icon) #link(
          link_prefix + username,
        )[#link_text#username]]
    ]
  ]

  let custom-social(icon, dest, body) = [
    #if emphasise [
      #emph[#text(socials-colour)[#fa-icon(icon) #link(dest, body)]]
    ] else [
      #text(socials-colour)[#fa-icon(icon) #link(dest, body)]
    ]
  ]

  let address-social(icon, body) = [
    #if emphasise [
      #emph[#text(socials-colour)[#fa-icon(icon) #body]]
    ] else [
      #text(socials-colour)[#fa-icon(icon) #body]
    ]
  ]

  let socialsDict = (
    // key: (faIcon, linkPrefix)
    phone: ("phone", "tel:"),
    email: ("envelope", "mailto:"),
    github: ("github", "https://github.com/"),
    linkedin: ("linkedin", "https://linkedin.com/in/"),
    x: ("x-twitter", "https://twitter.com/"),
    bluesky: ("bluesky", "https://bsky.app/profile/"),
  )

  let socialsList = ()
  for entry in socials {
    assert(type(entry) == array, message: "Invalid social entry type.")
    assert(entry.len() == 2, message: "Invalid social entry length.")
    let (key, value) = entry
    if type(value) == str {
      if (key == "address") {
        socialsList.push(address-social("house", value))
      } else {
        if key not in socialsDict {
          panic("Unknown social key: " + key)
        }
        let (icon, linkPrefix) = socialsDict.at(key)
        socialsList.push(social(icon, linkPrefix, value))
      }
    } else if type(value) == array {
      assert(value.len() == 3, message: "Invalid social entry: " + key)
      let (icon, dest, body) = value
      socialsList.push(custom-social(icon, dest, body))
    } else {
      panic("Invalid social entry: " + entry)
    }
  }

  let socialStack = stack(
    dir: ttb,
    spacing: 0.5em,
    ..socialsList,
  )

  let imageStack = []

  if image != none {
    let imageFramed = []

    if image-frame-stroke == none {
      // no frame
      imageFramed = image
    } else {
      if image-frame-stroke == auto {
        // default stroke
        image-frame-stroke = 1pt + colour
      } else {
        image-frame-stroke = stroke(image-frame-stroke)
        if image-frame-stroke.paint == auto {
          // use the main colour by default
          // fields on stroke are not yet mutable
          image-frame-stroke = stroke((
            paint: colour,
            thickness: image-frame-stroke.thickness,
            cap: image-frame-stroke.cap,
            join: image-frame-stroke.join,
            dash: image-frame-stroke.dash,
            mitre-limit: image-frame-stroke.mitre-limit,
          ))
        }
      }
      imageFramed = rect(image, stroke: image-frame-stroke)
    }

    imageStack = stack(
      dir: ltr,
      h(1em),
      imageFramed,
    )
  }

  stack(
    dir: ltr,
    titleStack,
    align(
      right + top,
      socialStack,
    ),
    imageStack,
  )
}

#let moderner-cv(
  name: [],
  subtitle: [CV],
  social: (:),
  colour: moderncv-blue,
  subtitle-colour: light-gray,
  socials-colour: light-gray,
  emphasise-header: false,
  lang: "en",
  font: "New Computer Modern",
  image: none,
  image-frame-stroke: auto,
  paper: "a4",
  margin: (
    top: 10mm,
    bottom: 15mm,
    left: 15mm,
    right: 15mm,
  ),
  show-footer: true,
  body,
) = [
  #set page(
    paper: paper,
    margin: margin,
  )
  #set text(
    font: font,
    lang: lang,
  )

  #show heading: it => {
    set text(weight: "regular")
    set text(colour)
    set block(above: 0pt)
    _cv-line(
      [],
      [#it.body],
      above: 1em,
    )
  }
  #show heading.where(level: 1): it => {
    set text(weight: "regular")
    set text(colour)
    _cv-line(
      align: horizon,
      [#box(fill: colour, width: 28mm, height: 0.25em)],
      [#it.body],
      above: 1em,
    )
  }

  #_header(
    title: name,
    subtitle: subtitle,
    image: image,
    image-frame-stroke: image-frame-stroke,
    colour: colour,
    subtitle-colour: subtitle-colour,
    socials-colour: socials-colour,
    socials: social,
    emphasise: emphasise-header,
  )

  #body

  #if show-footer [
    #v(1fr, weak: false)
    #name\
    #datetime.today().display("[month repr:long] [day], [year]")
  ]
]

#let cv-line(left-side, right-side) = {
  _cv-line(
    align(right, left-side),
    par(right-side, justify: true),
  )
}

#let cv-entry(
  date: [],
  title: [],
  employer: [],
  ..description,
) = {
  let elements = (
    strong(title),
    emph(employer),
    ..description.pos(),
  )
  cv-line(
    date,
    elements.join(", "),
  )
}

#let cv-entry-multiline(
  date: [],
  title: [],
  employer: [],
  ..description,
) = {
  let elements = (
    strong(title),
    emph(employer),
    ..description.pos(),
  )
  cv-line(
    date,
    elements.slice(0, -1).join(", ")
      + linebreak()
      + text(
        size: 0.9em,
        elements.at(-1),
      ),
  )
}

#let cv-language(name: [], level: [], experience: [], comment: []) = {
  let years = if experience != 1 [years] else [year]
  _cv-line(
    align(right, name),
    stack(dir: ltr, [#level (#experience #years)], align(right, emph(comment))),
  )
}

#let cv-double-item(left-1, right-1, left-2, right-2) = {
  set block(below: 0pt)
  table(
    columns: (1fr, 2fr, 1fr, 2fr),
    stroke: none,
    align(right, left-1), right-1, align(right, left-2), right-2,
  )
}

#let cv-list-item(item) = {
  _cv-line(
    [],
    list(item),
  )
}

#let cv-list-double-item(item1, item2) = {
  set block(below: 0pt)
  table(
    columns: (1fr, 2.5fr, 2.5fr),
    stroke: none,
    [], list(item1), list(item2),
  )
}
