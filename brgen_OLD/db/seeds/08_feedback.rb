
create_feedback_user = User.create(
  username: "styret",
  email: "kontakt@brgen.no",
  gender: "male",
  name: "Styret brgen.no",
  password: "we7AeTai4oo"
)

@forum = Forem::Forum.find_by_name("Generelt")
@feedback = @forum.topics.build({
  subject: "Gi oss tilbakemelding",
  posts_attributes: [
   text: "Har du forslag til hvordan vi kan gjøre Brgen bedre? Vennligst gi oss ris og ros her."
  ]
})
@feedback.user = create_feedback_user
@feedback.save!
@feedback.update_column(:created_at, (rand * 5).days.ago)
@feedback.update_column(:updated_at, @feedback.created_at)
@feedback.update_column(:published_at, @feedback.created_at)
@feedback.update_column(:state, "published")
@feedback.posts.first.update_column(:created_at, @feedback.created_at)
@feedback.posts.first.update_column(:updated_at, @feedback.created_at)
likes_3rd(@feedback)
@forum.increment(:published_topics_count)
@forum.save!

# Acts as a HTML template for optimistic reply posting

# Corresponds to `replyUrl` in `posting.js`

reply = @feedback.posts.build({ text: "Kjempeflott!", reply_to_id: @feedback.posts.first.id })
reply.user = create_anon_user
reply.save!
reply.update_column(:created_at, @feedback.created_at + (rand * 1440).minutes)
reply.update_column(:updated_at, reply.created_at)

