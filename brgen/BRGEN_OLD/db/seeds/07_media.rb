
@forum = Forem::Forum.find_by_name("Sentrum")
@skysskortet_1 = @forum.topics.build({
  subject: "Har du skaffa deg Skysskortet? Sjå korleis her",
  posts_attributes: [
    text: "http://youtube.com/watch?v=gUrTZ-VEAPY

http://youtube.com/watch?v=cME22FE_Q5g

http://youtube.com/watch?v=GFaI5_B3xuM

Mer info: http://skyss.no/"
  ]
})
@skysskortet_1.user = create_anon_user
@skysskortet_1.save!
@skysskortet_1.update_column(:created_at, (rand * 5).days.ago)
@skysskortet_1.update_column(:updated_at, @skysskortet_1.created_at)
@skysskortet_1.update_column(:published_at, @skysskortet_1.created_at)
@skysskortet_1.update_column(:state, "published")
@skysskortet_1.posts.first.update_column(:created_at, @skysskortet_1.created_at)
@skysskortet_1.posts.first.update_column(:updated_at, @skysskortet_1.created_at)
likes_4th(@skysskortet_1)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@skysskortet_2 = @forum.topics.build({
  subject: "Skyss Bybanen",
  posts_attributes: [
    text: "http://youtube.com/watch?v=VmtixwM2AN4

Mer info: http://skyss.no/"
  ]
})
@skysskortet_2.user = create_anon_user
@skysskortet_2.save!
@skysskortet_2.update_column(:created_at, (rand * 5).days.ago)
@skysskortet_2.update_column(:updated_at, @skysskortet_2.created_at)
@skysskortet_2.update_column(:published_at, @skysskortet_2.created_at)
@skysskortet_2.update_column(:state, "published")
@skysskortet_2.posts.first.update_column(:created_at, @skysskortet_2.created_at)
@skysskortet_2.posts.first.update_column(:updated_at, @skysskortet_2.created_at)
# likes_4th(@skysskortet_2)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Generelt")
@bergen_medieby = @forum.topics.build({ subject: "Bergen Medieby", posts_attributes: [text: "http://youtube.com/watch?v=XFee6U2OfyI"] })
@bergen_medieby.user = create_anon_user
@bergen_medieby.save!
@bergen_medieby.update_column(:created_at, (rand * 5).days.ago)
@bergen_medieby.update_column(:updated_at, @bergen_medieby.created_at)
@bergen_medieby.update_column(:published_at, @bergen_medieby.created_at)
@bergen_medieby.update_column(:state, "published")
@bergen_medieby.posts.first.update_column(:created_at, @bergen_medieby.created_at)
@bergen_medieby.posts.first.update_column(:updated_at, @bergen_medieby.created_at)
likes_4th(@bergen_medieby)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Generelt")
@nye_flesland = @forum.topics.build({ subject: "Nye Flesland", posts_attributes: [text: "http://youtube.com/watch?v=wC5hwlqHvFo"] })
@nye_flesland.user = create_anon_user
@nye_flesland.save!
@nye_flesland.update_column(:created_at, (rand * 5).days.ago)
@nye_flesland.update_column(:updated_at, @nye_flesland.created_at)
@nye_flesland.update_column(:published_at, @nye_flesland.created_at)
@nye_flesland.update_column(:state, "published")
@nye_flesland.posts.first.update_column(:created_at, @nye_flesland.created_at)
@nye_flesland.posts.first.update_column(:updated_at, @nye_flesland.created_at)
likes_4th(@nye_flesland)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Artister, musikere")
@fuck_your_xbox = @forum.topics.build({ subject: "Johann - Fuck Your Xbox", posts_attributes: [text: "http://soundcloud.com/jmanaf/fuck-your-xbox"] })
@fuck_your_xbox.user = create_anon_user
@fuck_your_xbox.save!
@fuck_your_xbox.update_column(:created_at, (rand * 5).days.ago)
@fuck_your_xbox.update_column(:updated_at, @fuck_your_xbox.created_at)
@fuck_your_xbox.update_column(:published_at, @fuck_your_xbox.created_at)
@fuck_your_xbox.update_column(:state, "published")
@fuck_your_xbox.posts.first.update_column(:created_at, @fuck_your_xbox.created_at)
@fuck_your_xbox.posts.first.update_column(:updated_at, @fuck_your_xbox.created_at)
likes_3rd(@fuck_your_xbox)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Haukeland sykehus")
@lyden_av_haukeland = @forum.topics.build({ subject: "Lyden av Haukeland", posts_attributes: [text: "http://vimeo.com/54920394"] })
@lyden_av_haukeland.user = create_anon_user
@lyden_av_haukeland.save!
@lyden_av_haukeland.update_column(:created_at, (rand * 5).days.ago)
@lyden_av_haukeland.update_column(:updated_at, @lyden_av_haukeland.created_at)
@lyden_av_haukeland.update_column(:published_at, @lyden_av_haukeland.created_at)
@lyden_av_haukeland.update_column(:state, "published")
@lyden_av_haukeland.posts.first.update_column(:created_at, @lyden_av_haukeland.created_at)
@lyden_av_haukeland.posts.first.update_column(:updated_at, @lyden_av_haukeland.created_at)
likes_4th(@lyden_av_haukeland)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Artister, musikere")
@me_in_you = @forum.topics.build({ subject: "Kings of Convenience - Me in You", posts_attributes: [text: "http://youtube.com/watch?v=aFwZDNsG-Os"] })
@me_in_you.user = create_anon_user
@me_in_you.save!
@me_in_you.update_column(:created_at, (rand * 5).days.ago)
@me_in_you.update_column(:updated_at, @me_in_you.created_at)
@me_in_you.update_column(:published_at, @me_in_you.created_at)
@me_in_you.update_column(:state, "published")
@me_in_you.posts.first.update_column(:created_at, @me_in_you.created_at)
@me_in_you.posts.first.update_column(:updated_at, @me_in_you.created_at)
likes_3rd(@me_in_you)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Artister, musikere")
@misread = @forum.topics.build({ subject: "Kings of Convenience - Misread", posts_attributes: [text: "http://youtube.com/watch?v=WOxE7IRizjI"] })
@misread.user = create_anon_user
@misread.save!
@misread.update_column(:created_at, (rand * 5).days.ago)
@misread.update_column(:updated_at, @misread.created_at)
@misread.update_column(:published_at, @misread.created_at)
@misread.update_column(:state, "published")
@misread.posts.first.update_column(:created_at, @misread.created_at)
@misread.posts.first.update_column(:updated_at, @misread.created_at)
likes_3rd(@misread)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Artister, musikere")
@id_rather_dance_with_you = @forum.topics.build({ subject: "Kings of Convenience - I'd Rather Dance With You", posts_attributes: [text: "http://youtube.com/watch?v=OczRpuGKTfY"] })
@id_rather_dance_with_you.user = create_anon_user
@id_rather_dance_with_you.save!
@id_rather_dance_with_you.update_column(:created_at, (rand * 5).days.ago)
@id_rather_dance_with_you.update_column(:updated_at, @id_rather_dance_with_you.created_at)
@id_rather_dance_with_you.update_column(:published_at, @id_rather_dance_with_you.created_at)
@id_rather_dance_with_you.update_column(:state, "published")
@id_rather_dance_with_you.posts.first.update_column(:created_at, @id_rather_dance_with_you.created_at)
@id_rather_dance_with_you.posts.first.update_column(:updated_at, @id_rather_dance_with_you.created_at)
likes_3rd(@id_rather_dance_with_you)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Artister, musikere")
@toxic_girl = @forum.topics.build({ subject: "Kings of Convenience - Toxic Girl", posts_attributes: [text: "http://youtube.com/watch?v=_9UauaXTXUI"] })
@toxic_girl.user = create_anon_user
@toxic_girl.save!
@toxic_girl.update_column(:created_at, (rand * 5).days.ago)
@toxic_girl.update_column(:updated_at, @toxic_girl.created_at)
@toxic_girl.update_column(:published_at, @toxic_girl.created_at)
@toxic_girl.update_column(:state, "published")
@toxic_girl.posts.first.update_column(:created_at, @toxic_girl.created_at)
@toxic_girl.posts.first.update_column(:updated_at, @toxic_girl.created_at)
likes_2nd(@toxic_girl)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Artister, musikere")
@burning = @forum.topics.build({ subject: "The Whitest Boy Alive - Burning", posts_attributes: [text: "https://youtube.com/watch?v=fAWurnyKZUM"] })
@burning.user = create_anon_user
@burning.save!
@burning.update_column(:created_at, (rand * 5).days.ago)
@burning.update_column(:updated_at, @burning.created_at)
@burning.update_column(:published_at, @burning.created_at)
@burning.update_column(:state, "published")
@burning.posts.first.update_column(:created_at, @burning.created_at)
@burning.posts.first.update_column(:updated_at, @burning.created_at)
likes_2nd(@burning)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Artister, musikere")
@golden_cage = @forum.topics.build({ subject: "The Whitest Boy Alive - Golden Cage", posts_attributes: [text: "https://youtube.com/watch?v=h-lcNuvrocs"|
@golden_cage.posts.first.update_column(:updated_at, @golden_cage.created_at)
likes_2nd(@golden_cage)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@climax = @forum.topics.build({ subject: "J Dilla - Climax", posts_attributes: [text: "http://youtube.com/watch?v=oahCrjD5QDc"] })
@climax.user = create_anon_user
@climax.save!
@climax.update_column(:created_at, (rand * 5).days.ago)
@climax.update_column(:updated_at, @climax.created_at)
@climax.update_column(:published_at, @climax.created_at)
@climax.update_column(:state, "published")
@climax.posts.first.update_column(:created_at, @climax.created_at)
@climax.posts.first.update_column(:updated_at, @climax.created_at)
likes_3rd(@climax)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@the_facts = @forum.topics.build({ subject: "Afta-1 - The Facts", posts_attributes: [text: "http://youtube.com/watch?v=qvKucBwxom8"] })
@the_facts.user = create_anon_user
@the_facts.save!
@the_facts.update_column(:created_at, (rand * 5).days.ago)
@the_facts.update_column(:updated_at, @the_facts.created_at)
@the_facts.update_column(:published_at, @the_facts.created_at)
@the_facts.update_column(:state, "published")
@the_facts.posts.first.update_column(:created_at, @the_facts.created_at)
@the_facts.posts.first.update_column(:updated_at, @the_facts.created_at)
likes_4th(@the_facts)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@four_nia = @forum.topics.build({ subject: "Afta-1 - 4nia", posts_attributes: [text: "http://youtube.com/watch?v=fzBuXumxDX4"] })
@four_nia.user = create_anon_user
@four_nia.save!
@four_nia.update_column(:created_at, (rand * 5).days.ago)
@four_nia.update_column(:updated_at, @four_nia.created_at)
@four_nia.update_column(:published_at, @four_nia.created_at)
@four_nia.update_column(:state, "published")
@four_nia.posts.first.update_column(:created_at, @four_nia.created_at)
@four_nia.posts.first.update_column(:updated_at, @four_nia.created_at)
likes_3rd(@four_nia)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@sway_close = @forum.topics.build({ subject: "Afta-1 - Sway Close", posts_attributes: [text: "http://youtube.com/watch?v=Ok4nJKvpQk4"] })
@sway_close.user = create_anon_user
@sway_close.save!
@sway_close.update_column(:created_at, (rand * 5).days.ago)
@sway_close.update_column(:updated_at, @sway_close.created_at)
@sway_close.update_column(:published_at, @sway_close.created_at)
@sway_close.update_column(:state, "published")
@sway_close.posts.first.update_column(:created_at, @sway_close.created_at)
@sway_close.posts.first.update_column(:updated_at, @sway_close.created_at)
likes_4th(@sway_close)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@love_suite = @forum.topics.build({ subject: "Afta-1 - Love Suite", posts_attributes: [text: "http://youtube.com/watch?v=K1xMAP6gTTM"] })
@love_suite.user = create_anon_user
@love_suite.save!
@love_suite.update_column(:created_at, (rand * 5).days.ago)
@love_suite.update_column(:updated_at, @love_suite.created_at)
@love_suite.update_column(:published_at, @love_suite.created_at)
@love_suite.update_column(:state, "published")
@love_suite.posts.first.update_column(:created_at, @love_suite.created_at)
@love_suite.posts.first.update_column(:updated_at, @love_suite.created_at)
likes_3rd(@love_suite)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@tiden_flyver = @forum.topics.build({ subject: "Afta-1 feat. Boom Clap Bachelors - Tiden Flyver", posts_attributes: [text: "http://afta1.bandcamp.com/track/tiden-flyver"] })
@tiden_flyver.user = create_anon_user
@tiden_flyver.save!
@tiden_flyver.update_column(:created_at, (rand * 5).days.ago)
@tiden_flyver.update_column(:updated_at, @tiden_flyver.created_at)
@tiden_flyver.update_column(:published_at, @tiden_flyver.created_at)
@tiden_flyver.update_column(:state, "published")
@tiden_flyver.posts.first.update_column(:created_at, @tiden_flyver.created_at)
@tiden_flyver.posts.first.update_column(:updated_at, @tiden_flyver.created_at)
likes_3rd(@tiden_flyver)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@location_within = @forum.topics.build({ subject: "Afta-1 - Location Within", posts_attributes: [text: "http://youtube.com/watch?v=9jiG0mv1rbM"] })
@location_within.user = create_anon_user
@location_within.save!
@location_within.update_column(:created_at, (rand * 5).days.ago)
@location_within.update_column(:updated_at, @location_within.created_at)
@location_within.update_column(:published_at, @location_within.created_at)
@location_within.update_column(:state, "published")
@location_within.posts.first.update_column(:created_at, @location_within.created_at)
@location_within.posts.first.update_column(:updated_at, @location_within.created_at)
# likes_4th(@location_within)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@mysterious_vibes = @forum.topics.build({ subject: "Afta-1 - Mysterious Vibes", posts_attributes: [text: "http://youtube.com/watch?v=_6N2Kdn4cO4"] })
@mysterious_vibes.user = create_anon_user
@mysterious_vibes.save!
@mysterious_vibes.update_column(:created_at, (rand * 5).days.ago)
@mysterious_vibes.update_column(:updated_at, @mysterious_vibes.created_at)
@mysterious_vibes.update_column(:published_at, @mysterious_vibes.created_at)
@mysterious_vibes.update_column(:state, "published")
@mysterious_vibes.posts.first.update_column(:created_at, @mysterious_vibes.created_at)
@mysterious_vibes.posts.first.update_column(:updated_at, @mysterious_vibes.created_at)
likes_3rd(@mysterious_vibes)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@flyerthanshe = @forum.topics.build({ subject: "Afta-1 - Flyerthanshe", posts_attributes: [text: "http://afta1.bandcamp.com/track/flyerthanshe"] })
@flyerthanshe.user = create_anon_user
@flyerthanshe.save!
@flyerthanshe.update_column(:created_at, (rand * 5).days.ago)
@flyerthanshe.update_column(:updated_at, @flyerthanshe.created_at)
@flyerthanshe.update_column(:published_at, @flyerthanshe.created_at)
@flyerthanshe.update_column(:state, "published")
@flyerthanshe.posts.first.update_column(:created_at, @flyerthanshe.created_at)
@flyerthanshe.posts.first.update_column(:updated_at, @flyerthanshe.created_at)
likes_3rd(@flyerthanshe)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@superheroes = @forum.topics.build({ subject: "Afta-1 feat. Esthero - Superheroes", posts_attributes: [text: "http://afta1.bandcamp.com/track/superheroes"] })
@superheroes.user = create_anon_user
@superheroes.save!
@superheroes.update_column(:created_at, (rand * 5).days.ago)
@superheroes.update_column(:updated_at, @superheroes.created_at)
@superheroes.update_column(:published_at, @superheroes.created_at)
@superheroes.update_column(:state, "published")
@superheroes.posts.first.update_column(:created_at, @superheroes.created_at)
@superheroes.posts.first.update_column(:updated_at, @superheroes.created_at)
likes_3rd(@superheroes)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@inside_outside_sunlight = @forum.topics.build({ subject: "Into Sometimes - Inside Outside Sunlight", posts_attributes: [text: "http://vimeo.com/95884340"] })
@inside_outside_sunlight.user = create_anon_user
@inside_outside_sunlight.save!
@inside_outside_sunlight.update_column(:created_at, (rand * 5).days.ago)
@inside_outside_sunlight.update_column(:updated_at, @inside_outside_sunlight.created_at)
@inside_outside_sunlight.update_column(:published_at, @inside_outside_sunlight.created_at)
@inside_outside_sunlight.update_column(:state, "published")
@inside_outside_sunlight.posts.first.update_column(:created_at, @inside_outside_sunlight.created_at)
@inside_outside_sunlight.posts.first.update_column(:updated_at, @inside_outside_sunlight.created_at)
likes_4th(@inside_outside_sunlight)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@two_seven_six = @forum.topics.build({ subject: "Into Sometimes - 276", posts_attributes: [text: "http://vimeo.com/100308033"] })
@two_seven_six.user = create_anon_user
@two_seven_six.save!
@two_seven_six.update_column(:created_at, (rand * 5).days.ago)
@two_seven_six.update_column(:updated_at, @two_seven_six.created_at)
@two_seven_six.update_column(:published_at, @two_seven_six.created_at)
@two_seven_six.update_column(:state, "published")
@two_seven_six.posts.first.update_column(:created_at, @two_seven_six.created_at)
@two_seven_six.posts.first.update_column(:updated_at, @two_seven_six.created_at)
likes_3rd(@two_seven_six)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

# @forum = Forem::Forum.find_by_name("Musikk")
# @into_sometimes_3 = @forum.topics.build({ subject: "Into Sometimes 3", posts_attributes: [text: "http://vimeo.com/112021711"] })
# @into_sometimes_3.user = create_anon_user
# @into_sometimes_3.save!
# @into_sometimes_3.update_column(:created_at, (rand * 5).days.ago)
# @into_sometimes_3.update_column(:updated_at, @into_sometimes_3.created_at)
# @into_sometimes_3.update_column(:published_at, @into_sometimes_3.created_at)
# @into_sometimes_3.update_column(:state, "published")
# @into_sometimes_3.posts.first.update_column(:created_at, @into_sometimes_3.created_at)
# @into_sometimes_3.posts.first.update_column(:updated_at, @into_sometimes_3.created_at)
# likes_3rd(@into_sometimes_3)
# @forum.increment(:published_topics_count)
# @forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@ll3 = @forum.topics.build({ subject: "Elestial 0088 - LL 3", posts_attributes: [text: "http://soundcloud.com/user902364644/elestial-0088-ll-3"] })
@ll3.user = create_anon_user
@ll3.save!
@ll3.update_column(:created_at, (rand * 5).days.ago)
@ll3.update_column(:updated_at, @ll3.created_at)
@ll3.update_column(:published_at, @ll3.created_at)
@ll3.update_column(:state, "published")
@ll3.posts.first.update_column(:created_at, @ll3.created_at)
@ll3.posts.first.update_column(:updated_at, @ll3.created_at)
likes_4th(@ll3)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

# @forum = Forem::Forum.find_by_name("Musikk")
# @steam_beta = @forum.topics.build({ subject: "Afta-1 - Steam Beta", posts_attributes: [text: "http://afta1.bandcamp.com/track/steam-beta"] })
# @steam_beta.user = create_anon_user
# @steam_beta.save!
# @steam_beta.update_column(:created_at, (rand * 5).days.ago)
# @steam_beta.update_column(:updated_at, @steam_beta.created_at)
# @steam_beta.update_column(:published_at, @steam_beta.created_at)
# @steam_beta.update_column(:state, "published")
# @steam_beta.posts.first.update_column(:created_at, @steam_beta.created_at)
# @steam_beta.posts.first.update_column(:updated_at, @steam_beta.created_at)
# likes_4th(@steam_beta)
# @forum.increment(:published_topics_count)
# @forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@from_the_sun = @forum.topics.build({ subject: "Afta-1 - From The Sun", posts_attributes: [text: "http://afta1.bandcamp.com/track/from-the-sun"] })
@from_the_sun.user = create_anon_user
@from_the_sun.save!
@from_the_sun.update_column(:created_at, (rand * 5).days.ago)
@from_the_sun.update_column(:updated_at, @from_the_sun.created_at)
@from_the_sun.update_column(:published_at, @from_the_sun.created_at)
@from_the_sun.update_column(:state, "published")
@from_the_sun.posts.first.update_column(:created_at, @from_the_sun.created_at)
@from_the_sun.posts.first.update_column(:updated_at, @from_the_sun.created_at)
likes_3rd(@from_the_sun)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@yellow = @forum.topics.build({ subject: "Afta-1 - Yellow", posts_attributes: [text: "http://soundcloud.com/user90480461/yellow-1"] })
@yellow.user = create_anon_user
@yellow.save!
@yellow.update_column(:created_at, (rand * 5).days.ago)
@yellow.update_column(:updated_at, @yellow.created_at)
@yellow.update_column(:published_at, @yellow.created_at)
@yellow.update_column(:state, "published")
@yellow.posts.first.update_column(:created_at, @yellow.created_at)
@yellow.posts.first.update_column(:updated_at, @yellow.created_at)
likes_2nd(@yellow)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@blue = @forum.topics.build({ subject: "Afta-1 - Blue", posts_attributes: [text: "http://soundcloud.com/user680533152/blue-1"] })
@blue.user = create_anon_user
@blue.save!
@blue.update_column(:created_at, (rand * 5).days.ago)
@blue.update_column(:updated_at, @blue.created_at)
@blue.update_column(:published_at, @blue.created_at)
@blue.update_column(:state, "published")
@blue.posts.first.update_column(:created_at, @blue.created_at)
@blue.posts.first.update_column(:updated_at, @blue.created_at)
likes_2nd(@blue)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@moons_pulse = @forum.topics.build({ subject: "Infinite Skies - Moon's Pulse", posts_attributes: [text: "http://soundcloud.com/infinitekies/moons-pulse"] })
@moons_pulse.user = create_anon_user
@moons_pulse.save!
@moons_pulse.update_column(:created_at, (rand * 5).days.ago)
@moons_pulse.update_column(:updated_at, @moons_pulse.created_at)
@moons_pulse.update_column(:published_at, @moons_pulse.created_at)
@moons_pulse.update_column(:state, "published")
@moons_pulse.posts.first.update_column(:created_at, @moons_pulse.created_at)
@moons_pulse.posts.first.update_column(:updated_at, @moons_pulse.created_at)
likes_3rd(@moons_pulse)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@tape_b_side = @forum.topics.build({ subject: "Afta-1 - Tape B Side", posts_attributes: [text: "http://soundcloud.com/user137256228/tape-b-side"] })
@tape_b_side.user = create_anon_user
@tape_b_side.save!
@tape_b_side.update_column(:created_at, (rand * 5).days.ago)
@tape_b_side.update_column(:updated_at, @tape_b_side.created_at)
@tape_b_side.update_column(:published_at, @tape_b_side.created_at)
@tape_b_side.update_column(:state, "published")
@tape_b_side.posts.first.update_column(:created_at, @tape_b_side.created_at)
@tape_b_side.posts.first.update_column(:updated_at, @tape_b_side.created_at)
likes_3rd(@tape_b_side)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

# @forum = Forem::Forum.find_by_name("Musikk")
# @ad_placement = @forum.topics.build({ subject: "Pronounced Love - Like A Tattoo", posts_attributes: [text: "http://soundcloud.com/elestialdaisy/like-a-tattoo"] })
# @ad_placement.user = create_anon_user
# @ad_placement.save!
# @ad_placement.update_column(:created_at, (rand * 5).days.ago)
# @ad_placement.update_column(:updated_at, @ad_placement.created_at)
# @ad_placement.update_column(:published_at, @ad_placement.created_at)
# @ad_placement.update_column(:state, "published")
# @ad_placement.posts.first.update_column(:created_at, @ad_placement.created_at)
# @ad_placement.posts.first.update_column(:updated_at, @ad_placement.created_at)
# likes_3rd(@ad_placement)
# @forum.increment(:published_topics_count)
# @forum.save!

# -------------------------------------------------

# @forum = Forem::Forum.find_by_name("Musikk")
# @sky_garden = @forum.topics.build({ subject: "Pronouned Love - Sky Garden", posts_attributes: [text: "http://soundcloud.com/elestialdaisy/sky-garden"] })
# @sky_garden.user = create_anon_user
# @sky_garden.save!
# @sky_garden.update_column(:created_at, (rand * 5).days.ago)
# @sky_garden.update_column(:updated_at, @sky_garden.created_at)
# @sky_garden.update_column(:published_at, @sky_garden.created_at)
# @sky_garden.update_column(:state, "published")
# @sky_garden.posts.first.update_column(:created_at, @sky_garden.created_at)
# @sky_garden.posts.first.update_column(:updated_at, @sky_garden.created_at)
# likes_4th(@sky_garden)
# @forum.increment(:published_topics_count)
# @forum.save!

# -------------------------------------------------

# @forum = Forem::Forum.find_by_name("Musikk")
# @qam_daseon_robin_hannibal = @forum.topics.build({ subject: "Pronouned Love - Qam Daseon Robin Hannibal", posts_attributes: [text: "http://soundcloud.com/elestialdaisy/qam-daseon-robin-hannibal"] })
# @qam_daseon_robin_hannibal.user = create_anon_user
# @qam_daseon_robin_hannibal.save!
# @qam_daseon_robin_hannibal.update_column(:created_at, (rand * 5).days.ago)
# @qam_daseon_robin_hannibal.update_column(:updated_at, @qam_daseon_robin_hannibal.created_at)
# @qam_daseon_robin_hannibal.update_column(:published_at, @qam_daseon_robin_hannibal.created_at)
# @qam_daseon_robin_hannibal.update_column(:state, "published")
# @qam_daseon_robin_hannibal.posts.first.update_column(:created_at, @qam_daseon_robin_hannibal.created_at)
# @qam_daseon_robin_hannibal.posts.first.update_column(:updated_at, @qam_daseon_robin_hannibal.created_at)
# likes_4th(@qam_daseon_robin_hannibal)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@undefined = @forum.topics.build({ subject: "Afta-1 - Undefined (Full Album)", posts_attributes: [text: "http://youtube.com/watch?v=t1mgsMyxRH0"] })
@undefined.user = create_anon_user
@undefined.save!
@undefined.update_column(:created_at, (rand * 5).days.ago)
@undefined.update_column(:updated_at, @undefined.created_at)
@undefined.update_column(:published_at, @undefined.created_at)
@undefined.update_column(:state, "published")
@undefined.posts.first.update_column(:created_at, @undefined.created_at)
@undefined.posts.first.update_column(:updated_at, @undefined.created_at)
likes_3rd(@undefined)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@lighthouse = @forum.topics.build({ subject: "Afta-1 - Lighthouse (Full Album)", posts_attributes: [text: "http://youtube.com/watch?v=T-FauwuQ9hs"] })
@lighthouse.user = create_anon_user
@lighthouse.save!
@lighthouse.update_column(:created_at, (rand * 5).days.ago)
@lighthouse.update_column(:updated_at, @lighthouse.created_at)
@lighthouse.update_column(:published_at, @lighthouse.created_at)
@lighthouse.update_column(:state, "published")
@lighthouse.posts.first.update_column(:created_at, @lighthouse.created_at)
@lighthouse.posts.first.update_column(:updated_at, @lighthouse.created_at)
likes_3rd(@lighthouse)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@coming_home_to_you = @forum.topics.build({ subject: "coming home to you >>", posts_attributes: [text: "http://soundcloud.com/blvnkets/coming-home-to-you"] })
@coming_home_to_you.user = create_anon_user
@coming_home_to_you.save!
@coming_home_to_you.update_column(:created_at, (rand * 5).days.ago)
@coming_home_to_you.update_column(:updated_at, @coming_home_to_you.created_at)
@coming_home_to_you.update_column(:published_at, @coming_home_to_you.created_at)
@coming_home_to_you.update_column(:state, "published")
@coming_home_to_you.posts.first.update_column(:created_at, @coming_home_to_you.created_at)
@coming_home_to_you.posts.first.update_column(:updated_at, @coming_home_to_you.created_at)
likes_3rd(@coming_home_to_you)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@wmtd = @forum.topics.build({ subject: "WMTD (Instrumental Beta)", posts_attributes: [text: "https://soundcloud.com/pronouncedlove/wmtd-instrumental-beta"] })
@wmtd.user = create_anon_user
@wmtd.save!
@wmtd.update_column(:created_at, (rand * 5).days.ago)
@wmtd.update_column(:updated_at, @wmtd.created_at)
@wmtd.update_column(:published_at, @wmtd.created_at)
@wmtd.update_column(:state, "published")
@wmtd.posts.first.update_column(:created_at, @wmtd.created_at)
@wmtd.posts.first.update_column(:updated_at, @wmtd.created_at)
likes_2nd(@wmtd)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@back_against_the_wall = @forum.topics.build({ subject: "Chase Swayze - Back Against The Wall", posts_attributes: [text: "http://soundcloud.com/user902364644/chase-swayze-back-against-the-wall"] })
@back_against_the_wall.user = create_anon_user
@back_against_the_wall.save!
@back_against_the_wall.update_column(:created_at, (rand * 5).days.ago)
@back_against_the_wall.update_column(:updated_at, @back_against_the_wall.created_at)
@back_against_the_wall.update_column(:published_at, @back_against_the_wall.created_at)
@back_against_the_wall.update_column(:state, "published")
@back_against_the_wall.posts.first.update_column(:created_at, @back_against_the_wall.created_at)
@back_against_the_wall.posts.first.update_column(:updated_at, @back_against_the_wall.created_at)
likes_3rd(@back_against_the_wall)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@round_the_outside = @forum.topics.build({ subject: "Karriem Riggins - Round The Outside", posts_attributes: [text: "http://vimeo.com/55635771"] })
@round_the_outside.user = create_anon_user
@round_the_outside.save!
@round_the_outside.update_column(:created_at, (rand * 5).days.ago)
@round_the_outside.update_column(:updated_at, @round_the_outside.created_at)
@round_the_outside.update_column(:published_at, @round_the_outside.created_at)
@round_the_outside.update_column(:state, "published")
@round_the_outside.posts.first.update_column(:created_at, @round_the_outside.created_at)
@round_the_outside.posts.first.update_column(:updated_at, @round_the_outside.created_at)
likes_4th(@round_the_outside)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@oooooooooaaaaaaa = @forum.topics.build({ subject: "Karriem Riggins - Oooooooooaaaaaaa", posts_attributes: [text: "http://soundcloud.com/user902364644/karriem-riggins-oooooooooaaaaaaa"] })
@oooooooooaaaaaaa.user = create_anon_user
@oooooooooaaaaaaa.save!
@oooooooooaaaaaaa.update_column(:created_at, (rand * 5).days.ago)
@oooooooooaaaaaaa.update_column(:updated_at, @oooooooooaaaaaaa.created_at)
@oooooooooaaaaaaa.update_column(:published_at, @oooooooooaaaaaaa.created_at)
@oooooooooaaaaaaa.update_column(:state, "published")
@oooooooooaaaaaaa.posts.first.update_column(:created_at, @oooooooooaaaaaaa.created_at)
@oooooooooaaaaaaa.posts.first.update_column(:updated_at, @oooooooooaaaaaaa.created_at)
# likes_4th(@oooooooooaaaaaaa)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@solar_waves = @forum.topics.build({ subject: "Yesterdays New Quintet - Solar Waves", posts_attributes: [text: "http://youtube.com/watch?v=6s4PnaaaxpU"] })
@solar_waves.user = create_anon_user
@solar_waves.save!
@solar_waves.update_column(:created_at, (rand * 5).days.ago)
@solar_waves.update_column(:updated_at, @solar_waves.created_at)
@solar_waves.update_column(:published_at, @solar_waves.created_at)
@solar_waves.update_column(:state, "published")
@solar_waves.posts.first.update_column(:created_at, @solar_waves.created_at)
@solar_waves.posts.first.update_column(:updated_at, @solar_waves.created_at)
# likes_4th(@solar_waves)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@tea_leaf_dancers = @forum.topics.build({ subject: "Flying Lotus - Tea Leaf Dancers", posts_attributes: [text: "http://youtube.com/watch?v=GW1NTN5vMyY"] })
@tea_leaf_dancers.user = create_anon_user
@tea_leaf_dancers.save!
@tea_leaf_dancers.update_column(:created_at, (rand * 5).days.ago)
@tea_leaf_dancers.update_column(:updated_at, @tea_leaf_dancers.created_at)
@tea_leaf_dancers.update_column(:published_at, @tea_leaf_dancers.created_at)
@tea_leaf_dancers.update_column(:state, "published")
@tea_leaf_dancers.posts.first.update_column(:created_at, @tea_leaf_dancers.created_at)
@tea_leaf_dancers.posts.first.update_column(:updated_at, @tea_leaf_dancers.created_at)
# likes_4th(@tea_leaf_dancers)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@tiny_tortures = @forum.topics.build({ subject: "Flying Lotus - Tiny Tortures", posts_attributes: [text: "http://youtube.com/watch?v=TRNGpATRCrI"] })
@tiny_tortures.user = create_anon_user
@tiny_tortures.save!
@tiny_tortures.update_column(:created_at, (rand * 5).days.ago)
@tiny_tortures.update_column(:updated_at, @tiny_tortures.created_at)
@tiny_tortures.update_column(:published_at, @tiny_tortures.created_at)
@tiny_tortures.update_column(:state, "published")
@tiny_tortures.posts.first.update_column(:created_at, @tiny_tortures.created_at)
@tiny_tortures.posts.first.update_column(:updated_at, @tiny_tortures.created_at)
# likes_4th(@tiny_tortures)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@camel = @forum.topics.build({ subject: "Flying Lotus - Camel", posts_attributes: [text: "http://youtube.com/watch?v=sUDIgV6cUXE"] })
@camel.user = create_anon_user
@camel.save!
@camel.update_column(:created_at, (rand * 5).days.ago)
@camel.update_column(:updated_at, @camel.created_at)
@camel.update_column(:published_at, @camel.created_at)
@camel.update_column(:state, "published")
@camel.posts.first.update_column(:created_at, @camel.created_at)
@camel.posts.first.update_column(:updated_at, @camel.created_at)
# likes_4th(@camel)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@dolly = @forum.topics.build({ subject: "Flying Lotus + Ahu - Dolly (added efforts)", posts_attributes: [text: "http://youtube.com/watch?v=6z3lJ47gCjk"] })
@dolly.user = create_anon_user
@dolly.save!
@dolly.update_column(:created_at, (rand * 5).days.ago)
@dolly.update_column(:updated_at, @dolly.created_at)
@dolly.update_column(:published_at, @dolly.created_at)
@dolly.update_column(:state, "published")
@dolly.posts.first.update_column(:created_at, @dolly.created_at)
@dolly.posts.first.update_column(:updated_at, @dolly.created_at)
# likes_4th(@dolly)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@robertaflack = @forum.topics.build({ subject: "Flying Lotus - RobertaFlack (feat. Dolly)", posts_attributes: [text: "http://youtube.com/watch?v=_tNuowVSlKI"] })
@robertaflack.user = create_anon_user
@robertaflack.save!
@robertaflack.update_column(:created_at, (rand * 5).days.ago)
@robertaflack.update_column(:updated_at, @robertaflack.created_at)
@robertaflack.update_column(:published_at, @robertaflack.created_at)
@robertaflack.update_column(:state, "published")
@robertaflack.posts.first.update_column(:created_at, @robertaflack.created_at)
@robertaflack.posts.first.update_column(:updated_at, @robertaflack.created_at)
# likes_4th(@robertaflack)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@galaxy_in_janaki = @forum.topics.build({ subject: "Flying Lotus - Galaxy in Janaki", posts_attributes: [text: "http://youtube.com/watch?v=YxQWT05OYs0"] })
@galaxy_in_janaki.user = create_anon_user
@galaxy_in_janaki.save!
@galaxy_in_janaki.update_column(:created_at, (rand * 5).days.ago)
@galaxy_in_janaki.update_column(:updated_at, @galaxy_in_janaki.created_at)
@galaxy_in_janaki.update_column(:published_at, @galaxy_in_janaki.created_at)
@galaxy_in_janaki.update_column(:state, "published")
@galaxy_in_janaki.posts.first.update_column(:created_at, @galaxy_in_janaki.created_at)
@galaxy_in_janaki.posts.first.update_column(:updated_at, @galaxy_in_janaki.created_at)
likes_4th(@galaxy_in_janaki)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@endless_white = @forum.topics.build({ subject: "Flying Lotus - Endless White", posts_attributes: [text: "http://youtube.com/watch?v=c74uVSjCiOs"] })
@endless_white.user = create_anon_user
@endless_white.save!
@endless_white.update_column(:created_at, (rand * 5).days.ago)
@endless_white.update_column(:updated_at, @endless_white.created_at)
@endless_white.update_column(:published_at, @endless_white.created_at)
@endless_white.update_column(:state, "published")
@endless_white.posts.first.update_column(:created_at, @endless_white.created_at)
@endless_white.posts.first.update_column(:updated_at, @endless_white.created_at)
# likes_4th(@endless_white)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@golden_diva = @forum.topics.build({ subject: "Flying Lotus - Golden Diva", posts_attributes: [text: "http://youtube.com/watch?v=cq4txkEpmhs"] })
@golden_diva.user = create_anon_user
@golden_diva.save!
@golden_diva.update_column(:created_at, (rand * 5).days.ago)
@golden_diva.update_column(:updated_at, @golden_diva.created_at)
@golden_diva.update_column(:published_at, @golden_diva.created_at)
@golden_diva.update_column(:state, "published")
@golden_diva.posts.first.update_column(:created_at, @golden_diva.created_at)
@golden_diva.posts.first.update_column(:updated_at, @golden_diva.created_at)
# likes_4th(@golden_diva)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@princess_toadstool = @forum.topics.build({ subject: "FLYamSAM - Princess Toadstool", posts_attributes: [text: "http://youtube.com/watch?v=wz4eUwhDhA0"] })
@princess_toadstool.user = create_anon_user
@princess_toadstool.save!
@princess_toadstool.update_column(:created_at, (rand * 5).days.ago)
@princess_toadstool.update_column(:updated_at, @princess_toadstool.created_at)
@princess_toadstool.update_column(:published_at, @princess_toadstool.created_at)
@princess_toadstool.update_column(:state, "published")
@princess_toadstool.posts.first.update_column(:created_at, @princess_toadstool.created_at)
@princess_toadstool.posts.first.update_column(:updated_at, @princess_toadstool.created_at)
# likes_4th(@princess_toadstool)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@the_offbeat = @forum.topics.build({ subject: "FLYamSAM - The Offbeat (Adult Swim bump)", posts_attributes: [text: "http://youtube.com/watch?v=rqoaXKTwoPs"] })
@the_offbeat.user = create_anon_user
@the_offbeat.save!
@the_offbeat.update_column(:created_at, (rand * 5).days.ago)
@the_offbeat.update_column(:updated_at, @the_offbeat.created_at)
@the_offbeat.update_column(:published_at, @the_offbeat.created_at)
@the_offbeat.update_column(:state, "published")
@the_offbeat.posts.first.update_column(:created_at, @the_offbeat.created_at)
@the_offbeat.posts.first.update_column(:updated_at, @the_offbeat.created_at)
# likes_4th(@the_offbeat)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@speak_to_robots = @forum.topics.build({ subject: "FLYamSAM - Speak To Robots", posts_attributes: [text: "http://youtube.com/watch?v=X08cJ6H-XOU"] })
@speak_to_robots.user = create_anon_user
@speak_to_robots.save!
@speak_to_robots.update_column(:created_at, (rand * 5).days.ago)
@speak_to_robots.update_column(:updated_at, @speak_to_robots.created_at)
@speak_to_robots.update_column(:published_at, @speak_to_robots.created_at)
@speak_to_robots.update_column(:state, "published")
@speak_to_robots.posts.first.update_column(:created_at, @speak_to_robots.created_at)
@speak_to_robots.posts.first.update_column(:updated_at, @speak_to_robots.created_at)
# likes_4th(@speak_to_robots)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@ooh_bay = @forum.topics.build({ subject: "JJ Burton - Ohh Bay!!! (Ohh Baby)", posts_attributes: [text: "http://soundcloud.com/labelwho/jj-burton-ohh-bay-ohh-baby"] })
@ooh_bay.user = create_anon_user
@ooh_bay.save!
@ooh_bay.update_column(:created_at, (rand * 5).days.ago)
@ooh_bay.update_column(:updated_at, @ooh_bay.created_at)
@ooh_bay.update_column(:published_at, @ooh_bay.created_at)
@ooh_bay.update_column(:state, "published")
@ooh_bay.posts.first.update_column(:created_at, @ooh_bay.created_at)
@ooh_bay.posts.first.update_column(:updated_at, @ooh_bay.created_at)
likes_3rd(@ooh_bay)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@dust = @forum.topics.build({ subject: "Recloose - Dust feat. Jneiro Jarel", posts_attributes: [text: "http://youtube.com/watch?v=9x2S8ZPkJmQ"] })
@dust.user = create_anon_user
@dust.save!
@dust.update_column(:created_at, (rand * 5).days.ago)
@dust.update_column(:updated_at, @dust.created_at)
@dust.update_column(:published_at, @dust.created_at)
@dust.update_column(:state, "published")
@dust.posts.first.update_column(:created_at, @dust.created_at)
@dust.posts.first.update_column(:updated_at, @dust.created_at)
likes_4th(@dust)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@motion_trouble = @forum.topics.build({ subject: "Matthewdavid - Motion Trouble", posts_attributes: [text: "http://vimeo.com/21118169"] })
@motion_trouble.user = create_anon_user
@motion_trouble.save!
@motion_trouble.update_column(:created_at, (rand * 5).days.ago)
@motion_trouble.update_column(:updated_at, @motion_trouble.created_at)
@motion_trouble.update_column(:published_at, @motion_trouble.created_at)
@motion_trouble.update_column(:state, "published")
@motion_trouble.posts.first.update_column(:created_at, @motion_trouble.created_at)
@motion_trouble.posts.first.update_column(:updated_at, @motion_trouble.created_at)
# likes_4th(@motion_trouble)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@in_my_world = @forum.topics.build({ subject: "Matthewdavid - In My World", posts_attributes: [text: "http://soundcloud.com/brainfeeder/sets/matthewdavid-in-my-world"] })
@in_my_world.user = create_anon_user
@in_my_world.save!
@in_my_world.update_column(:created_at, (rand * 5).days.ago)
@in_my_world.update_column(:updated_at, @in_my_world.created_at)
@in_my_world.update_column(:published_at, @in_my_world.created_at)
@in_my_world.update_column(:state, "published")
@in_my_world.posts.first.update_column(:created_at, @in_my_world.created_at)
@in_my_world.posts.first.update_column(:updated_at, @in_my_world.created_at)
# likes_4th(@in_my_world)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@sex = @forum.topics.build({ subject: "Slugabed - Sex", posts_attributes: [text: "http://youtube.com/watch?v=o2Ddzd1L2tE"] })
@sex.user = create_anon_user
@sex.save!
@sex.update_column(:created_at, (rand * 5).days.ago)
@sex.update_column(:updated_at, @sex.created_at)
@sex.update_column(:published_at, @sex.created_at)
@sex.update_column(:state, "published")
@sex.posts.first.update_column(:created_at, @sex.created_at)
@sex.posts.first.update_column(:updated_at, @sex.created_at)
# likes_4th(@sex)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@toeachizown = @forum.topics.build({ subject: "DâM-FunK - Toeachizown", posts_attributes: [text: "http://youtube.com/watch?v=S53cOe51W-s"] })
@toeachizown.user = create_anon_user
@toeachizown.save!
@toeachizown.update_column(:created_at, (rand * 5).days.ago)
@toeachizown.update_column(:updated_at, @toeachizown.created_at)
@toeachizown.update_column(:published_at, @toeachizown.created_at)
@toeachizown.update_column(:state, "published")
@toeachizown.posts.first.update_column(:created_at, @toeachizown.created_at)
@toeachizown.posts.first.update_column(:updated_at, @toeachizown.created_at)
# likes_4th(@toeachizown)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@tenfold = @forum.topics.build({ subject: "Thundercat - Tenfold", posts_attributes: [text: "http://youtube.com/watch?v=Y210VB49dHw"] })
@tenfold.user = create_anon_user
@tenfold.save!
@tenfold.update_column(:created_at, (rand * 5).days.ago)
@tenfold.update_column(:updated_at, @tenfold.created_at)
@tenfold.update_column(:published_at, @tenfold.created_at)
@tenfold.update_column(:state, "published")
@tenfold.posts.first.update_column(:created_at, @tenfold.created_at)
@tenfold.posts.first.update_column(:updated_at, @tenfold.created_at)
# likes_4th(@tenfold)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@without_you = @forum.topics.build({ subject: "Thundercat - Without You", posts_attributes: [text: "http://youtube.com/watch?v=XlufecqB9l0"] })
@without_you.user = create_anon_user
@without_you.save!
@without_you.update_column(:created_at, (rand * 5).days.ago)
@without_you.update_column(:updated_at, @without_you.created_at)
@without_you.update_column(:published_at, @without_you.created_at)
@without_you.update_column(:state, "published")
@without_you.posts.first.update_column(:created_at, @without_you.created_at)
@without_you.posts.first.update_column(:updated_at, @without_you.created_at)
likes_4th(@without_you)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@heartbreaks_setbacks = @forum.topics.build({ subject: "Thundercat - Heartbreaks + Setbacks", posts_attributes: [text: "http://youtube.com/watch?v=PqL5vSFFwxw"] })
@heartbreaks_setbacks.user = create_anon_user
@heartbreaks_setbacks.save!
@heartbreaks_setbacks.update_column(:created_at, (rand * 5).days.ago)
@heartbreaks_setbacks.update_column(:updated_at, @heartbreaks_setbacks.created_at)
@heartbreaks_setbacks.update_column(:published_at, @heartbreaks_setbacks.created_at)
@heartbreaks_setbacks.update_column(:state, "published")
@heartbreaks_setbacks.posts.first.update_column(:created_at, @heartbreaks_setbacks.created_at)
@heartbreaks_setbacks.posts.first.update_column(:updated_at, @heartbreaks_setbacks.created_at)
# likes_4th(@heartbreaks_setbacks)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@them_changes = @forum.topics.build({ subject: "Thundercat - 'Them Changes'", posts_attributes: [text: "http://soundcloud.com/brainfeeder/thundercat-them-changes"] })
@them_changes.user = create_anon_user
@them_changes.save!
@them_changes.update_column(:created_at, (rand * 5).days.ago)
@them_changes.update_column(:updated_at, @them_changes.created_at)
@them_changes.update_column(:published_at, @them_changes.created_at)
@them_changes.update_column(:state, "published")
@them_changes.posts.first.update_column(:created_at, @them_changes.created_at)
@them_changes.posts.first.update_column(:updated_at, @them_changes.created_at)
# likes_4th(@them_changes)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@moments = @forum.topics.build({ subject: "Teebs - Moments", posts_attributes: [text: "http://vimeo.com/27273208"] })
@moments.user = create_anon_user
@moments.save!
@moments.update_column(:created_at, (rand * 5).days.ago)
@moments.update_column(:updated_at, @moments.created_at)
@moments.update_column(:published_at, @moments.created_at)
@moments.update_column(:state, "published")
@moments.posts.first.update_column(:created_at, @moments.created_at)
@moments.posts.first.update_column(:updated_at, @moments.created_at)
# likes_4th(@moments)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@sachi_chords = @forum.topics.build({ subject: "Teebs - Sachi Chords", posts_attributes: [text: "http://youtube.com/watch?v=0sl_lX51mTk"] })
@sachi_chords.user = create_anon_user
@sachi_chords.save!
@sachi_chords.update_column(:created_at, (rand * 5).days.ago)
@sachi_chords.update_column(:updated_at, @sachi_chords.created_at)
@sachi_chords.update_column(:published_at, @sachi_chords.created_at)
@sachi_chords.update_column(:state, "published")
@sachi_chords.posts.first.update_column(:created_at, @sachi_chords.created_at)
@sachi_chords.posts.first.update_column(:updated_at, @sachi_chords.created_at)
likes_3rd(@sachi_chords)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@estara = @forum.topics.build({ subject: "Teebs - Estara", posts_attributes: [text: "http://soundcloud.com/brainfeeder/sets/teebs-e-s-t-a-r-a"] })
@estara.user = create_anon_user
@estara.save!
@estara.update_column(:created_at, (rand * 5).days.ago)
@estara.update_column(:updated_at, @estara.created_at)
@estara.update_column(:published_at, @estara.created_at)
@estara.update_column(:state, "published")
@estara.posts.first.update_column(:created_at, @estara.created_at)
@estara.posts.first.update_column(:updated_at, @estara.created_at)
# likes_4th(@estara)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@mother_lode = @forum.topics.build({ subject: "Thom Yorke - The Mother Lode", posts_attributes: [text: "http://youtube.com/watch?v=Hu2koH2dZyI"] })
@mother_lode.user = create_anon_user
@mother_lode.save!
@mother_lode.update_column(:created_at, (rand * 5).days.ago)
@mother_lode.update_column(:updated_at, @mother_lode.created_at)
@mother_lode.update_column(:published_at, @mother_lode.created_at)
@mother_lode.update_column(:state, "published")
@mother_lode.posts.first.update_column(:created_at, @mother_lode.created_at)
@mother_lode.posts.first.update_column(:updated_at, @mother_lode.created_at)
likes_3rd(@mother_lode)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@mirror_maru = @forum.topics.build({ subject: "Cashmere Cat - Mirror Maru", posts_attributes: [text: "http://soundcloud.com/cashmerecat/mirrormaru"] })
@mirror_maru.user = create_anon_user
@mirror_maru.save!
@mirror_maru.update_column(:created_at, (rand * 5).days.ago)
@mirror_maru.update_column(:updated_at, @mirror_maru.created_at)
@mirror_maru.update_column(:published_at, @mirror_maru.created_at)
@mirror_maru.update_column(:state, "published")
@mirror_maru.posts.first.update_column(:created_at, @mirror_maru.created_at)
@mirror_maru.posts.first.update_column(:updated_at, @mirror_maru.created_at)
# likes_4th(@mirror_maru)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@fine_lines = @forum.topics.build({ subject: "Deffery - Fine Line(s) feat. Alex Isley", posts_attributes: [text: "http://soundcloud.com/deffery/fine-line-s-feat-alex-isley"] })
@fine_lines.user = create_anon_user
@fine_lines.save!
@fine_lines.update_column(:created_at, (rand * 5).days.ago)
@fine_lines.update_column(:updated_at, @fine_lines.created_at)
@fine_lines.update_column(:published_at, @fine_lines.created_at)
@fine_lines.update_column(:state, "published")
@fine_lines.posts.first.update_column(:created_at, @fine_lines.created_at)
@fine_lines.posts.first.update_column(:updated_at, @fine_lines.created_at)
likes_3rd(@fine_lines)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@hideaway_headshell = @forum.topics.build({ subject: "Clever Austin - Hide-away Headshell #1", posts_attributes: [text: "http://soundcloud.com/clever-austin/cleveraustin-wondercore-mix"] })
@hideaway_headshell.user = create_anon_user
@hideaway_headshell.save!
@hideaway_headshell.update_column(:created_at, (rand * 5).days.ago)
@hideaway_headshell.update_column(:updated_at, @hideaway_headshell.created_at)
@hideaway_headshell.update_column(:published_at, @hideaway_headshell.created_at)
@hideaway_headshell.update_column(:state, "published")
@hideaway_headshell.posts.first.update_column(:created_at, @hideaway_headshell.created_at)
@hideaway_headshell.posts.first.update_column(:updated_at, @hideaway_headshell.created_at)
likes_4th(@hideaway_headshell)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@dont_mean_a_thing = @forum.topics.build({ subject: "Lapalux - Don't Mean A Thing", posts_attributes: [text: "http://youtube.com/watch?v=6nTIvNtLUuI"] })
@dont_mean_a_thing.user = create_anon_user
@dont_mean_a_thing.save!
@dont_mean_a_thing.update_column(:created_at, (rand * 5).days.ago)
@dont_mean_a_thing.update_column(:updated_at, @dont_mean_a_thing.created_at)
@dont_mean_a_thing.update_column(:published_at, @dont_mean_a_thing.created_at)
@dont_mean_a_thing.update_column(:state, "published")
@dont_mean_a_thing.posts.first.update_column(:created_at, @dont_mean_a_thing.created_at)
@dont_mean_a_thing.posts.first.update_column(:updated_at, @dont_mean_a_thing.created_at)
likes_3rd(@dont_mean_a_thing)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Musikk")
@levelup = @forum.topics.build({ subject: "Samuel Truth - LevelUp", posts_attributes: [text: "http://youtube.com/watch?v=XHjt8s5RaEU"] })
@levelup.user = create_anon_user
@levelup.save!
@levelup.update_column(:created_at, (rand * 5).days.ago)
@levelup.update_column(:updated_at, @levelup.created_at)
@levelup.update_column(:published_at, @levelup.created_at)
@levelup.update_column(:state, "published")
@levelup.posts.first.update_column(:created_at, @levelup.created_at)
@levelup.posts.first.update_column(:updated_at, @levelup.created_at)
likes_4th(@levelup)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Minde")
@gate_minde = @forum.topics.build({ subject: "Gate 1 - Minde", posts_attributes: [text: "http://youtube.com/watch?v=5niVTAN2dKo"] })
@gate_minde.user = create_anon_user
@gate_minde.save!
@gate_minde.update_column(:created_at, (rand * 5).days.ago)
@gate_minde.update_column(:updated_at, @gate_minde.created_at)
@gate_minde.update_column(:published_at, @gate_minde.created_at)
@gate_minde.update_column(:state, "published")
@gate_minde.posts.first.update_column(:created_at, @gate_minde.created_at)
@gate_minde.posts.first.update_column(:updated_at, @gate_minde.created_at)
# likes_4th(@gate_minde)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Fyllingsdalen")
@gate_fyllingsdalen = @forum.topics.build({ subject: "Gate 2 - Fyllingsdalen", posts_attributes: [text: "http://youtube.com/watch?v=VTiZ2MaQ82E"] })
@gate_fyllingsdalen.user = create_anon_user
@gate_fyllingsdalen.save!
@gate_fyllingsdalen.update_column(:created_at, (rand * 5).days.ago)
@gate_fyllingsdalen.update_column(:updated_at, @gate_fyllingsdalen.created_at)
@gate_fyllingsdalen.update_column(:published_at, @gate_fyllingsdalen.created_at)
@gate_fyllingsdalen.update_column(:state, "published")
@gate_fyllingsdalen.posts.first.update_column(:created_at, @gate_fyllingsdalen.created_at)
@gate_fyllingsdalen.posts.first.update_column(:updated_at, @gate_fyllingsdalen.created_at)
# likes_4th(@gate_fyllingsdalen)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Fana")
@gate_fana = @forum.topics.build({ subject: "Gate 3 - Fana", posts_attributes: [text: "http://youtube.com/watch?v=YshwMHUarlg"] })
@gate_fana.user = create_anon_user
@gate_fana.save!
@gate_fana.update_column(:created_at, (rand * 5).days.ago)
@gate_fana.update_column(:updated_at, @gate_fana.created_at)
@gate_fana.update_column(:published_at, @gate_fana.created_at)
@gate_fana.update_column(:state, "published")
@gate_fana.posts.first.update_column(:created_at, @gate_fana.created_at)
@gate_fana.posts.first.update_column(:updated_at, @gate_fana.created_at)
# likes_4th(@gate_fana)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Sandviken")
@gate_sandviken = @forum.topics.build({ subject: "Gate 4 - Sandviken", posts_attributes: [text: "http://youtube.com/watch?v=InwHhYKlLUQ"] })
@gate_sandviken.user = create_anon_user
@gate_sandviken.save!
@gate_sandviken.update_column(:created_at, (rand * 5).days.ago)
@gate_sandviken.update_column(:updated_at, @gate_sandviken.created_at)
@gate_sandviken.update_column(:published_at, @gate_sandviken.created_at)
@gate_sandviken.update_column(:state, "published")
@gate_sandviken.posts.first.update_column(:created_at, @gate_sandviken.created_at)
@gate_sandviken.posts.first.update_column(:updated_at, @gate_sandviken.created_at)
# likes_4th(@gate_sandviken)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Loddefjord")
@gade_loddefjord = @forum.topics.build({ subject: "Gate 5 - Loddefjord", posts_attributes: [text: "http://youtube.com/watch?v=TS4T5mroO3U"] })
@gade_loddefjord.user = create_anon_user
@gade_loddefjord.save!
@gade_loddefjord.update_column(:created_at, (rand * 5).days.ago)
@gade_loddefjord.update_column(:updated_at, @gade_loddefjord.created_at)
@gade_loddefjord.update_column(:published_at, @gade_loddefjord.created_at)
@gade_loddefjord.update_column(:state, "published")
@gade_loddefjord.posts.first.update_column(:created_at, @gade_loddefjord.created_at)
@gade_loddefjord.posts.first.update_column(:updated_at, @gade_loddefjord.created_at)
# likes_4th(@gade_loddefjord)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Åsane")
@gate_aasane = @forum.topics.build({ subject: "Gate 6 - Åsane", posts_attributes: [text: "http://youtube.com/watch?v=ESIQ9zuEb78"] })
@gate_aasane.user = create_anon_user
@gate_aasane.save!
@gate_aasane.update_column(:created_at, (rand * 5).days.ago)
@gate_aasane.update_column(:updated_at, @gate_aasane.created_at)
@gate_aasane.update_column(:published_at, @gate_aasane.created_at)
@gate_aasane.update_column(:state, "published")
@gate_aasane.posts.first.update_column(:created_at, @gate_aasane.created_at)
@gate_aasane.posts.first.update_column(:updated_at, @gate_aasane.created_at)
# likes_4th(@gate_aasane)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Løvstakken")
@gate_loevstakken = @forum.topics.build({ subject: "Gate 8 - Løvstakken", posts_attributes: [text: "http://youtube.com/watch?v=nr1L9ad1cVg"] })
@gate_loevstakken.user = create_anon_user
@gate_loevstakken.save!
@gate_loevstakken.update_column(:created_at, (rand * 5).days.ago)
@gate_loevstakken.update_column(:updated_at, @gate_loevstakken.created_at)
@gate_loevstakken.update_column(:published_at, @gate_loevstakken.created_at)
@gate_loevstakken.update_column(:state, "published")
@gate_loevstakken.posts.first.update_column(:created_at, @gate_loevstakken.created_at)
@gate_loevstakken.posts.first.update_column(:updated_at, @gate_loevstakken.created_at)
# likes_4th(@gate_loevstakken)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("LOL")
@airport_love = @forum.topics.build({ subject: "XXL Airport Love", posts_attributes: [text: "http://youtube.com/watch?v=y5pzhmGX1sk"] })
@airport_love.user = create_anon_user
@airport_love.save!
@airport_love.update_column(:created_at, (rand * 5).days.ago)
@airport_love.update_column(:updated_at, @airport_love.created_at)
@airport_love.update_column(:published_at, @airport_love.created_at)
@airport_love.update_column(:state, "published")
@airport_love.posts.first.update_column(:created_at, @airport_love.created_at)
@airport_love.posts.first.update_column(:updated_at, @airport_love.created_at)
# likes_4th(@airport_love)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("LOL")
@late_for_meeting = @forum.topics.build({ subject: "Late for meeting", posts_attributes: [text: "http://youtube.com/watch?v=wBqM2ytqHY4"] })
@late_for_meeting.user = create_anon_user
@late_for_meeting.save!
@late_for_meeting.update_column(:created_at, (rand * 5).days.ago)
@late_for_meeting.update_column(:updated_at, @late_for_meeting.created_at)
@late_for_meeting.update_column(:published_at, @late_for_meeting.created_at)
@late_for_meeting.update_column(:state, "published")
@late_for_meeting.posts.first.update_column(:created_at, @late_for_meeting.created_at)
@late_for_meeting.posts.first.update_column(:updated_at, @late_for_meeting.created_at)
# likes_4th(@late_for_meeting)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("LOL")
@fouseytube = @forum.topics.build({ subject: "fouseyTUBE - Harry Potter Dementor Prank", posts_attributes: [text: "http://youtube.com/watch?v=Vm7eSv8whG8"] })
@fouseytube.user = create_anon_user
@fouseytube.save!
@fouseytube.update_column(:created_at, (rand * 5).days.ago)
@fouseytube.update_column(:updated_at, @fouseytube.created_at)
@fouseytube.update_column(:published_at, @fouseytube.created_at)
@fouseytube.update_column(:state, "published")
@fouseytube.posts.first.update_column(:created_at, @fouseytube.created_at)
@fouseytube.posts.first.update_column(:updated_at, @fouseytube.created_at)
likes_4th(@fouseytube)
@forum.increment(:published_topics_count)
@forum.save!

# -------------------------------------------------

@forum = Forem::Forum.find_by_name("Reise")
@tourism_malaysia = @forum.topics.build({ subject: "Tourism Malaysia 2014", posts_attributes: [text: "http://youtube.com/watch?v=DoyB3PeHCLM"] })
@tourism_malaysia.user = create_anon_user
@tourism_malaysia.save!
@tourism_malaysia.update_column(:created_at, (rand * 5).days.ago)
@tourism_malaysia.update_column(:updated_at, @tourism_malaysia.created_at)
@tourism_malaysia.update_column(:published_at, @tourism_malaysia.created_at)
@tourism_malaysia.update_column(:state, "published")
@tourism_malaysia.posts.first.update_column(:created_at, @tourism_malaysia.created_at)
@tourism_malaysia.posts.first.update_column(:updated_at, @tourism_malaysia.created_at)
likes_4th(@tourism_malaysia)
@forum.increment(:published_topics_count)
@forum.save!

