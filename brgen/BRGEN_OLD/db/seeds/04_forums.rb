
forum_types = ForumType.create([
  {
   name: "Regular",
   value: "regular"
  },
  {
   name: "Ad",
   value: "ad"
  },
  {
   name: "Event",
   value: "event"
  }
])
regular_forum_type_id = ForumType.find_by_value("regular").id
ad_forum_type_id = ForumType.find_by_value("ad").id
event_forum_type_id = ForumType.find_by_value("event").id

# -------------------------------------------------

forums = Forem::Forum.create([

  #
  # Events
  #

  {
   # name: "Activities",
   name: "Aktiviteter",
   description: "_blank",
   forum_type_id: event_forum_type_id,
   category_id: Forem::Category.find_by_value("events").id
  },
  {
   # name: "Children, family",
   name: "Barn, familie",
   description: "_blank",
   forum_type_id: event_forum_type_id,
   category_id: Forem::Category.find_by_value("events").id
  },
  {
   # name: "Dance, drama",
   name: "Dans, drama",
   description: "_blank",
   forum_type_id: event_forum_type_id,
   category_id: Forem::Category.find_by_value("events").id
  },
  {
   # name: "Sports",
   name: "Sport, idrett",
   description: "_blank",
   forum_type_id: event_forum_type_id,
   category_id: Forem::Category.find_by_value("events").id
  },
  {
   # name: "Concerts, parties",
   name: "Konserter, fester",
   description: "_blank",
   forum_type_id: event_forum_type_id,
   category_id: Forem::Category.find_by_value("events").id
  },
  {
   # name: "Restaurants, cafes",
   name: "Restauranter, kaféer",
   description: "_blank",
   forum_type_id: event_forum_type_id,
   category_id: Forem::Category.find_by_value("events").id
  },
  {
   name: "Senior",
   description: "_blank",
   forum_type_id: event_forum_type_id,
   category_id: Forem::Category.find_by_value("events").id
  },
  {
   # name: "Night life",
   name: "Utesteder",
   description: "_blank",
   forum_type_id: event_forum_type_id,
   category_id: Forem::Category.find_by_value("events").id
  },

  {
   # name: "Exhibitions",
   name: "Utstillinger",
   description: "_blank",
   forum_type_id: event_forum_type_id,
   category_id: Forem::Category.find_by_value("events").id
  },

  #
  # Dating
  #

  {
   # name: "Women seeking men",
   name: "Kvinner søker menn",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("dating").id
  },
  {
   # name: "Women seeking women",
   name: "Kvinner søker kvinner",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("dating").id
  },
  {
   # name: "Men seeking women",
   name: "Menn søker kvinner",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("dating").id
  },
  {
   # name: "Men seeking men",
   name: "Menn søker menn",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("dating").id
  },
  {
   # name: "Just friends",
   name: "Bare venner",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("dating").id
  },
  {
   name: "Friends with benefits",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("dating").id
  },
  {
   # name: "Missed connections",
   name: "Tapte øyeblikk",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("dating").id
  },
  {
   # name: "Dating for dogs",
   name: "Dating for hunder",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("dating").id
  },

  #
  # Forums
  #

  {
   # name: "Artists, musicians",
   name: "Artister, musikere",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Photo",
   name: "Foto",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Parents",
   name: "Foreldre",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Research, science",
   name: "Forskning, vitenskap",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Norwegian Armed Forces",
   name: "Forsvaret",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "General",
   name: "Generelt",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Grafitti, street art",
   name: "Grafitti, gatekunst",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Pregnancy, infants",
   name: "Graviditet, spedbarn",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   name: "Haukeland sykehus",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Health, diet",
   name: "Helse, kosthold",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   name: "HiB",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Law",
   name: "Juss",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Career, education",
   name: "Karriere, utdanning",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Pets",
   name: "Kjæledyr",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Love, relationships",
   name: "Kjærlighet, samliv",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   name: "LOL",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Food, drinks",
   name: "Mat, drikke",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Fashion, cosmetics",
   name: "Mote, kosmetikk",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Music",
   name: "Musikk",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Politics",
   name: "Politikk",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Pop culture, literature",
   name: "Popkultur, litteratur",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Travel",
   name: "Reise",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Drugs",
   name: "Rus",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Advice",
   name: "Råd, veiledning",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Sexuality",
   name: "Seksualitet",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   name: "Shopping",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Single life",
   name: "Singelliv",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "School, homework",
   name: "Skole, leksehjelp",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Sports, exercise",
   name: "Sport, trening",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Languages",
   name: "Språk",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Beauty, fashion",
   name: "Skjønnhet, mote",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Underground",
   name: "Undergrunn",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },
  {
   # name: "Consumer, economics",
   name: "Forbruker, økonomi",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("forums").id
  },

  #
  # For sale
  #

  {
   # name: "Babies, kids",
   name: "Barn, unger",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Car, boat, MC",
   name: "Bil, båt, MC",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Tickets",
   name: "Billetter",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Business activities",
   name: "Næringsvirksomhet",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Barter",
   name: "Byttehandel",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Books, magazines",
   name: "Bøker, magasiner",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Computer, Internet",
   name: "Data, Internett",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Animals, equipment",
   name: "Dyr, utstyr",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   name: "DVD, BluRay, LP etc.",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Electronics, appliances",
   name: "Elektronikk, hvitevarer",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Parents, children",
   name: "Foreldre, barn",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Free",
   name: "Gratis",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Hobby, recreation",
   name: "Hobby, fritid",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Household, garden",
   name: "Hus, hage",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Clothes, shoes, accessories",
   name: "Klær, sko, tilbehør",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Arts, crafts",
   name: "Kunst, håndverk",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Toys, computer games",
   name: "Leker, dataspill",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Flea market, retro",
   name: "Loppemarked, retro",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Sound, light",
   name: "Lyd, lys",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Musical instruments",
   name: "Musikkinstrumenter",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Furniture, interior",
   name: "Møbler, interiør",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Sports, training equipment",
   name: "Sport, treningsutstyr",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Tools",
   name: "Verktøy",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },
  {
   # name: "Wanted",
   name: "Ønsket",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("for sale").id
  },

  #
  # Housing
  #

  {
   # name: "New buildings",
   name: "Nye boliger",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("housing").id
  },
  {
   # name: "Housing for rent",
   name: "Bolig til leie",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("housing").id
  },
  {
   # name: "Housing for sale",
   name: "Bolig til salgs",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("housing").id
  },
  {
   # name: "Bedsit, collective",
   name: "Hybel, kollektiv",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("housing").id
  },

  #
  # Jobs
  #

  {
   # name: "Kindergarten",
   name: "Barnehage",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "Shop clerk",
   name: "Butikkansatt",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "Research / research fellow",
   name: "Forskning / stipendiat",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "Health care",
   name: "Helsepersonell",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "Handyman",
   name: "Håndverker",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "Engineer",
   name: "Ingeniør",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "IT development",
   name: "IT-utvikling",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "Office, administration",
   name: "Kontor, administrasjon",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "Consultant",
   name: "Konsulent, veileder",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "Customer service",
   name: "Kundeservice",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "Management",
   name: "Ledelse",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "Physician",
   name: "Lege",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "Logistics, warehousing",
   name: "Logistikk, lager",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "Project management",
   name: "Prosjektledelse",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "Cleaning",
   name: "Renhold",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "Sales",
   name: "Salg",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "Nurse",
   name: "Sykepleier",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "Teaching, education",
   name: "Undervisning, pedagogikk",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },
  {
   # name: "Finance, accounting",
   name: "Økonomi, regnskap",
   description: "_blank",
   forum_type_id: ad_forum_type_id,
   category_id: Forem::Category.find_by_value("jobs").id
  },

  #
  # Boroughs
  #

  {
   name: "Arna",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Bergenhus",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Bryggen",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Bønes",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Danmarksplass",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Eidemarken",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Engen",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Fana",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Fantoft",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Fjellet",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Fløien",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Flaktveit",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Flesland",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Fyllingsdalen",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Gyldenpris",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Haukeland",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Kalfaret",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Kronstad",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Ladegården",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Laksevåg",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Landås",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Loddefjord",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Lønborg",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Løvstakken",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Marken",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Minde",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Møhlenpris",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Nattland",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Nesttun",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Nordnes",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Nygård",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Nøstet",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Paradis",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Salhus",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Sandsli",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Sandviken",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Sentrum",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Skansen",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Skuteviken",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Solheimsviken",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Storetveit",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Strandsiden",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Stølen",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Sydnes",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Sædalen",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Ulriken",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Vågsbunnen",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Ytrebygda",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Årstad",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  },
  {
   name: "Åsane",
   description: "_blank",
   forum_type_id: regular_forum_type_id,
   category_id: Forem::Category.find_by_value("boroughs").id
  }
])

