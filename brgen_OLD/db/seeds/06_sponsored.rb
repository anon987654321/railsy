
create_haukeland_user = User.create(
  username: "haukeland",
  email: "haukeland@brgen.no",
  gender: "male",
  name: "Helse Bergen",
  password: "hahy5Theeje"
)

@forum = Forem::Forum.find_by_name("Haukeland sykehus")
@haukeland = @forum.topics.build({
  subject: "Haukeland universitetssykehus på SoundCloud",
  #sponsored: true,
  posts_attributes: [
   text: "http://soundcloud.com/haukeland"
  ]
})
@haukeland.user = create_haukeland_user
@haukeland.save!
@haukeland.update_column(:created_at, (rand * 5).days.ago)
@haukeland.update_column(:updated_at, @haukeland.created_at)
@haukeland.update_column(:published_at, @haukeland.created_at)
@haukeland.update_column(:state, "published")
@haukeland.posts.first.update_column(:created_at, @haukeland.created_at)
@haukeland.posts.first.update_column(:updated_at, @haukeland.created_at)
likes_1st(@haukeland)
@forum.increment(:published_topics_count)
@forum.save!

