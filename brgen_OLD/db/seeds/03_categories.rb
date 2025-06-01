
categories = Forem::Category.create([
  {
   name: "Events",
   value: "events",
   expires_in: 0,
   newsworthy: true
  },
  {
   name: "Dating",
   value: "dating",
   expires_in: 0,
   newsworthy: true
  },
  {
 # name: "Forums",
   name: "Fora",
   value: "forums",
   expires_in: 0,
   newsworthy: true
  },
  {
 # name: "For sale",
   name: "Til salgs",
   value: "for sale",
   expires_in: 30,
   newsworthy: false
  },
  {
 # name: "Housing",
   name: "Bolig",
   value: "housing",
   expires_in: 30,
   newsworthy: false
  },
  {
 # name: "Jobs",
   name: "Jobb",
   value: "jobs",
   expires_in: 30,
   newsworthy: false
  },
  {
 # name: "Boroughs",
   name: "Bydeler",
   value: "boroughs",
   expires_in: 0,
   newsworthy: true
  }
])
Forem::Category.rebuild!

