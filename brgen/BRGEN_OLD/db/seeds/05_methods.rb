
# Put these in `~/.irbrc` for use through Rails console

def create_anon_user
  token = User.generate_token(:persistence_token)

  User.create(
    username: token,
    name: token,
    email: "#{ token }@example.com",
    gender: ["male", "female"].sample,
    password: token,
    password_confirmation: token,
    persistence_token: token
  )
end

def likes_1st(topic)
  if Rails.env.production?
    rand(444..555).times do
      create_anon_user

      Like.create({ post_id: topic.posts.first.id, user_id: User.last.id })
    end
  end
end

def likes_2nd(topic)
  if Rails.env.production?
    rand(333..444).times do
      create_anon_user

      Like.create({ post_id: topic.posts.first.id, user_id: User.last.id })
    end
  end
end

def likes_3rd(topic)
  if Rails.env.production?
    rand(222..333).times do
      create_anon_user

      Like.create({ post_id: topic.posts.first.id, user_id: User.last.id })
    end
  end
end

def likes_4th(topic)
  if Rails.env.production?
    rand(111..222).times do
      create_anon_user

      Like.create({ post_id: topic.posts.first.id, user_id: User.last.id })
    end
  end
end

