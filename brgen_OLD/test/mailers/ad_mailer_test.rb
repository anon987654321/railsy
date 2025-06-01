require 'test_helper'

class AdMailerTest < ActionMailer::TestCase

  def test_ad_forward
    @topic = forem_topics(:open_topic)
    reply = @topic.posts.build({ text: "reply to ad", email: "replier@example.com"})
    reply.user = users(:other_user)
    reply.save!

    email = AdMailer.ad_forward(@topic, reply).deliver

    assert !ActionMailer::Base.deliveries.empty?
    assert @topic.posts.first.email, email.to[0]
    assert "#{I18n.t :you_have_a_reply} - #{@topic.subject}", email.subject
    assert_match /#{main_app.forum_topic_path(@topic.forum, @topic)}/, email.body.encoded
  end

  def test_ad_confirm
    @topic = forem_forums(:ad_forum).topics.build
    @topic.subject = "A first topic"
    @topic.posts_attributes = [ { text: "This is the first topic.", email: "test@example.com" } ]
    @topic.user = users(:test_user)
    @topic.ad_confirmation_key = SecureRandom.hex
    @topic.save

    email = AdMailer.ad_confirm(@topic).deliver

    assert !ActionMailer::Base.deliveries.empty?
    assert @topic.posts.first.email, email.to[0]
    assert "Confirm - #{@topic.subject}", email.subject
    assert_match /#{main_app.confirm_ad_path(@topic, key: @topic.ad_confirmation_key)}/, email.body.encoded
  end
end

