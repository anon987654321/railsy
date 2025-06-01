Forem::TopicsHelper.class_eval do
  def link_to_latest_post(topic, tag)
    post_by_user_and_time(relevant_posts(topic).where("reply_type=?", "public").last, tag)
  end

  # -------------------------------------------------

  def trigger_description
    if !mobile?
      content_tag :span, "#{ t :comment }", class: "trigger_description arrow_bottom arrow_center"
    end
  end

  def reply_trigger(post, data_options)
    link_to main_app.new_reply_path(post.topic, replies: post.topic.public_posts.count, reply_to_id: post.id), data: data_options, class: "reply_trigger#{ ' progress_trigger' if mobile? }" do
      trigger_description
    end
  end

  def new_email_reply_trigger(post, data_options)
    link_to main_app.new_reply_path(post.topic, replies: post.topic.public_posts.count, reply_to_id: post.id, reply_type: "email"), data: data_options, class: "new_email_reply_trigger#{ ' progress_trigger' if mobile? }" do
      content_tag :label, "#{ t :send_anonymous_email }", class: "trigger_description arrow_bottom arrow_center"
    end
  end

  def reply_triggers(post)
    data_options = { behavior: "reply", topic: post.topic.id, post: post.id, transition: "#{ 'slide' if mobile? }", ajax: mobile? ? true : false }

    if post.topic.forum_type == ForumType.ad && !post.reply_to
      if post.topic.enable_comments
        reply_trigger(post, data_options)
      end

      if post.topic.posts.first
        new_email_reply_trigger(post, data_options)
      end
    else
      reply_trigger(post, data_options)
    end
  end

  # -------------------------------------------------

  def expires_in(topic)
    if topic.published?
      distance_of_time_in_words_to_now(topic.published_at + topic.category.expires_in.days)
    end
  end

private
  def last_post_for_topic(topic)
    topic.posts.by_created_at.where("reply_type=?", "regular").last
  end
end

