Forem::SubscriptionMailer.class_eval do
  def topic_reply(post_id, post_subscriber_id)
    @post = Forem::Post.find(post_id)
    @post_subscriber = Forem::Post.find(post_subscriber_id)

    mail(:to => @post_subscriber.email, :subject => I18n.t('forem.topic.received_reply'))
  end
end

