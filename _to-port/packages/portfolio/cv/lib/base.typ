#import "moderner-cv.typ": *

#set par(
  justify: true,
  spacing: 1em,
)

#let assert_set(value, message) = assert(value != none, message: message)

#let socials_list(tech_links, anonymous) = {
  let socials = if anonymous { (:) } else {
    (
      email: "kieranknowles11@hotmail.co.uk",
      github: "kieranknowles1",
      linkedin: "kieran-john-knowles",
      website: ("globe", "https://selwonk.uk", "selwonk.uk"),
    )
  }
  socials.insert("address", "Cramlington, UK")

  if not tech_links {
    let _ = socials.remove("github")
    let _ = socials.remove("website")
  }

  socials
}

#let template(
  statement: none,
  extra_skills: [],
  tech_links: none,
  title: none,
  anonymous: false,
) = [
  #{
    if anonymous {
      assert_set(title, "Title must be set for an anonymous CV")
    }
    assert_set(statement, "Statement cannot be empty")
    assert_set(tech_links, "Tech links must be a boolean")
  }

  #let job_entry(
    date: none,
    title: none,
    employer: none,
    job_type: none,
    description,
  ) = cv-entry-multiline(
    date: if anonymous { none } else { date },
    title: title,
    employer: if anonymous { job_type } else { employer },
    description,
  )

  #let education_entry(
    date: none,
    title: none,
    employer: none,
    result,
  ) = cv-entry-multiline(
    date: if anonymous { none } else { date },
    title: title,
    employer: if anonymous { none } else { employer },
    result,
  )

  #show: moderner-cv.with(
    paper: "a4",
    font: "DejaVu Sans",
    show-footer: false,

    name: if anonymous { title } else { "Kieran John Knowles" },
    lang: "en",
    social: socials_list(tech_links, anonymous),
  )

  #statement

  = Skills

  #extra_skills

  // TODO: Skills for non-technical CVs
  #if tech_links [
    #cv-language(
      name: [C++],
      level: [Expert Knowledge],
      experience: 3,
      comment: [Main language throughout masters degree.],
    )
    #cv-language(
      name: [Java],
      level: [Extensive Knowledge],
      experience: 1,
      comment: [Used for coursework at university.],
    )
    #cv-language(
      name: [TypeScript],
      level: [Extensive Knowledge],
      experience: 1,
      comment: [Language for dissertation.],
    )
    #cv-language(
      name: [Rust],
      level: [Basic Knowledge],
      experience: 1,
      comment: [Tools on personal desktop.],
    )
    #cv-language(
      name: [Python],
      level: [Extensive Knowledge],
      experience: 2,
      comment: [Used in scripts.],
    )
    #cv-language(
      name: [Linux],
      level: [Expert Knowledge],
      experience: 2,
      comment: [Used on both servers and desktops.],
    )
  ]

  = Experience

  #if tech_links [
    #if not anonymous [See portfolio hosted at https://selwonk.uk for technical experience.]
    #par([])
  ]

  #job_entry(
    date: [2022 -- now],
    title: [Volunteer],
    job_type: [Shop Assistant],
    employer: [Bright Charity, Northumbria Hospital],
    [
      - Serving customers
      - Responding effectively to customer queries
      - Resolving customer complaints
      - Accepting cash and card payments
      - Stocking and restocking
      - Ensuring cleanliness of the shop
      - Adhering to relevant health and safety regulations
    ],
  )

  #job_entry(
    date: [2022--2024],
    title: [Volunteer],
    job_type: [Animal Care],
    employer: [Pets Corner, Jesmond Dene],
    [
      - Cleaning enclosures
      - Preparing feed
      - Answering visitor questions and queries
      - Ensuring animal welfare, through conducting regular health checks
      - Constantly communicating with keepers to ensure animal healthcare standards were upheld
    ],
  )

  #job_entry(
    date: [as needed],
    title: [Website Maintainer],
    job_type: [Local Charity],
    employer: [Out of Sight Charity],
    [
      - Refactor website for better maintainability
      - Automate repetitive tasks for generating event pages
      - Correct broken links to point to the correct targets
      - Update information as requested by charity
      - Document changes as implemented
    ],
  )

  = Education

  #education_entry(
    date: [2024 -- 2025],
    title: "Computer Game Engineering Msc",
    employer: "Newcastle University",
    [Distinction],
  )

  #education_entry(
    date: [2020 -- 2024],
    title: "Computer Science Bsc",
    employer: "Northumbria University",
    [First-Class Honours],
  )

  #if tech_links and not anonymous [
    = Postgraduate Dissertation
    #cv-line([Title], [Vindolanda VR])
    #cv-line(
      [Description],
      [A virtual reality recreation of the Roman fort of Vindolanda and the
        nearby Castle Nick in the Unity game engine, featuring a tour guide to teach about the site, a tutorial for
        new VR users, and an archery range.],
    )
    #cv-bullets(
      [Skills Required],
      [
        - Historical research
        - Knowledge of the Unity engine
        - Attention to detail
        - Optimisation
        - Working to a deadline
      ],
    )

    = Undergraduate Dissertation
    #cv-line([Title], [CHEF - Cooking Helper for Everyone's Fridge])
    #cv-line([Supervisor], [Nick Dalton])
    #cv-line([Description], [A web application to help users find a variety of
      recipes based on the ingredients they have, and that are similar to those
      previously liked to help reduce food waste.])
    #cv-bullets(
      [Skills Required],
      [
        - REST API implementation
        - React front end development
        - Node back end development
      ],
    )
  ]

  #if not anonymous [
    = Interests

    #cv-line([Gaming], [Enjoy playing single-player and co-op games in a
      diverse range of genres. On PC and steam deck.])

    #cv-line([Animals], [Pet cats I enjoy spending time with. I love all
      animals, which led to volunteering at Jesmond Dene.])

    #cv-line(
      [Photography],
      [Keep a camera with me for any opportunities that arise.],
    )

    #cv-line([Walking], [Walk 5 miles several times a week.])
  ]

  = References
  Available upon request.
]
