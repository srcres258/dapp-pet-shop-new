#let base-font = "Noto Serif CJK SC"
#let mono-font = "Cascadia Mono"
#let heading-font = "Songti SC"

#set text(font: base-font, size: 13pt)
#set par(justify: true, first-line-indent: 2em, leading: 0.25em)

#let code-bg = luma(92%)
#let startstop-fill = rgb("#f7b2b2")
#let io-fill = rgb("#b8d9ff")
#let process-fill = rgb("#ffd8a8")
#let decision-fill = rgb("#b8f1ff")

#let bs = "\\"

#let code(text) = box(
  fill: code-bg,
  inset: (x: 4pt, y: 2pt),
  radius: 2pt,
)[
  #raw(text, lang: "txt")
]

#let _listing-lines(content) = {
  let rows = content.split("\n")
  table(
    columns: (auto, 1fr),
    stroke: none,
    inset: (x: 4pt, y: 1pt),
    ..rows.enumerate().map(((idx, line)) => (
      text(fill: gray.lighten(40%), size: 9pt)[#(idx + 1)],
      raw(line, lang: "txt"),
    )).flatten(),
  )
}

#let listing(path, number: true) = {
  let src = read(path)
  if number {
    block(
      fill: code-bg,
      inset: 8pt,
      radius: 3pt,
      stroke: (paint: luma(70%), thickness: 0.5pt),
    )[
      #set text(font: mono-font, size: 9pt)
      #_listing-lines(src)
    ]
  } else {
    block(
      fill: code-bg,
      inset: 8pt,
      radius: 3pt,
      stroke: (paint: luma(70%), thickness: 0.5pt),
    )[
      #set text(font: mono-font, size: 9pt)
      #raw(src, lang: "txt")
    ]
  }
}

#let wholepagefigure(body) = {
  pagebreak(to: "odd")
  set page(margin: 0mm, header: none, footer: none)
  align(center + horizon)[#body]
  pagebreak()
}

#let _title-page(title, suffix) = [
  #set page(margin: (top: 0mm, right: 0mm, bottom: 0mm, left: 0mm), header: none, footer: none)
  #v(1fr)
  #align(center)[#text(font: heading-font, size: 42pt, weight: "bold")[#title]]
  #v(18mm)
  #align(center)[#text(font: heading-font, size: 48pt, weight: "bold")[#suffix]]
  #v(1fr)
]

#let mancls(title: "", author: "", code: false, noheaders: false, body) = [
  #let suffix = if code { [软件源程序] } else { [使用说明书] }
  #let margin = if code {
    (top: 21mm, right: 25mm, bottom: 21mm, left: 25mm)
  } else {
    (top: 25mm, right: 25mm, bottom: 25mm, left: 25mm)
  }
  #let header_block = if noheaders {
    none
  } else {
    context [
      #set text(font: heading-font, size: 10pt)
      #grid(
        columns: (1fr, auto),
        align: (center, right),
        [#title],
        [第#counter(page).display("1") 页],
      )
    ]
  }

  #set page(
    paper: "a4",
    margin: margin,
    header: header_block,
    footer: none,
  )

  #_title-page(title, suffix)
  #pagebreak()

  #if not code [
    #outline(title: none)
    #pagebreak()
  ]

  #counter(page).update(1)

  #if code [
    #set par(first-line-indent: 0em, leading: 0.08em)
  ]

  #body
]
