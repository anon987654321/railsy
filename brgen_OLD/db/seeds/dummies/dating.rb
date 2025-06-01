@forum = Forem::Forum.find_by_name("Kvinner søker menn")
@topic1 = @forum.topics.build({ subject: "På jakt etter noe langsiktig", posts_attributes: [text: "Hei, jeg er en 37 år gammel kvinne som ønsker å finne noen å tilbringe resten av livet med. Jeg er egentlig litt skeptisk til nettdating, og er ennå ikke sikker på om dette er noen god idé. Takk.", email: "hakkiplaten@gmail.com"] })
@topic1.user = create_anon_user
@topic1.save!
@topic1.update_column(:created_at, (rand * 5).days.ago)
@topic1.update_column(:updated_at, @topic1.created_at)
@topic1.update_column(:published_at, @topic1.created_at)
@topic1.update_column(:state, "published")
@topic1.posts.first.update_column(:created_at, @topic1.created_at)
@topic1.posts.first.update_column(:updated_at, @topic1.created_at)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Kvinner søker kvinner")
@topic2 = @forum.topics.build({ subject: "Pen byjente søker det samme", posts_attributes: [text: "Jeg er en jente i midten av tjueårene. Jeg leter etter en morsom, attraktiv kvinne å henge med. Jeg er interessert i fjellklatring, kajakkpadling og fallskjermhopping. Jeg er attraktiv med langt mørkt brunt hår og brune øyne. Foretrekker høye kvinner ettersom jeg selv er ganske lav.

Send meg en epost hvis du har lyst til å møtes.", email: "hakkiplaten@gmail.com"] })
@topic2.user = create_anon_user
@topic2.save!
@topic2.update_column(:created_at, (rand * 5).days.ago)
@topic2.update_column(:updated_at, @topic2.created_at)
@topic2.update_column(:published_at, @topic2.created_at)
@topic2.update_column(:state, "published")
@topic2.posts.first.update_column(:created_at, @topic2.created_at)
@topic2.posts.first.update_column(:updated_at, @topic2.created_at)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Menn søker kvinner")
@topic3 = @forum.topics.build({ subject: "Sensuell massage", posts_attributes: [{ text: "La meg hjelpe deg å slappe av. Jeg er en attraktiv og renslig mann som ønsker å gi deg en hyggelig massasje.

Grip sjangsen og ta kontakt for en uforpliktende prat.", email: "hakkiplaten@gmail.com" }] })
@topic3.user = create_anon_user
@topic3.save!
@topic3.update_column(:created_at, (rand * 5).days.ago)
@topic3.update_column(:updated_at, @topic3.created_at)
@topic3.update_column(:published_at, @topic3.created_at)
@topic3.update_column(:state, "published")
@topic3.posts.first.update_column(:created_at, @topic3.created_at)
@topic3.posts.first.update_column(:updated_at, @topic3.created_at)
@forum.increment(:published_topics_count)
@forum.save!
reply1 = @topic3.posts.build({ text: "Ja du", reply_to_id: @topic3.posts.first.id })
reply1.user = create_anon_user
reply1.save!
reply1.update_column(:created_at, @topic3.created_at + (rand * 1440).minutes)
reply1.update_column(:updated_at, reply1.created_at)

