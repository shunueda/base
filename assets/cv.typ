#let data = json("cv.json")

#set page(
  paper: "us-letter",
  margin: (x: 0.5in, y: 0.5in),
)

#set par(justify: false, leading: 0.55em)

#set list(
  indent: 0.15in,
  body-indent: 0.5em,
  spacing: 0.6em,
  marker: text(size: 8pt, baseline: 0.15em)[•],
)

#show heading.where(level: 2): it => block(
  breakable: false,
)[
  #text(size: 14pt, weight: "regular")[#smallcaps(it.body)]
  #line(length: 100%, stroke: 0.5pt + black)
]

#let resume-subheading(company, duration, role, location) = block(
  width: 100%,
  breakable: false,
)[
  #grid(
    columns: (1fr, auto),
    row-gutter: 0.8em,
    strong(company), text(size: 10pt)[#duration],
    emph(role), text(size: 10pt, emph(location)),
  )
]

#align(center)[
  #text(size: 26pt, weight: "regular")[#smallcaps(data.name)] \
  #v(4pt)
  #text(size: 11pt)[
    #data.contacts.phone $|$
    #link("mailto:" + data.contacts.email)[#underline(data.contacts.email)] $|$
    #link("https://" + data.socials.linkedin)[#underline(
      data.socials.linkedin,
    )] $|$
    #link("https://" + data.socials.github)[#underline(data.socials.github)]
  ]
]

== Experience

#for exp in data.experiences [
  #resume-subheading(
    exp.company,
    exp.duration,
    exp.role,
    exp.location,
  )

  #for desc in exp.descriptions [
    - #desc
  ]
]

== Technical Skills

#for skill in data.skills [
  - *#skill.category*: #skill.items.join(", ")
]

== Education

#for edu in data.educations [
  #resume-subheading(
    edu.institution,
    edu.duration,
    edu.degree,
    edu.location,
  )
]
