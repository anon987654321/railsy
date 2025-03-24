require 'test_helper'

class Forem::TopicTest < ActiveSupport::TestCase
  def setup
    @attr = {
      subject: "A first topic",
      posts_attributes: [ { text: "This is the first topic." } ]
    }
    @topic = Forem::Topic.new(@attr)

    @topic.user = users(:test_user)
  end

  def test_topic_should_automatically_approved
    @topic.save!
    assert_equal "approved", @topic.state
  end

  def test_publish_topic_should_set_published_at
    @topic.save!
    @topic.publish!
    assert_not_nil @topic.published_at
    assert_equal "published", @topic.state
  end

  def test_confirm_topic_should_set_ad_confirmation_key
    @topic.save!
    @topic.posts.first.email = "test@example.com"
    @topic.confirm!
    assert_not_nil @topic.ad_confirmation_key
    assert_equal "pending_confirmation", @topic.state
  end

  def test_topic_is_not_valid_if_post_type_is_ad_and_email_is_blank
    @topic.post_type = "ad"
    assert !@topic.valid?
  end

  def test_topic_is_valid_if_post_type_is_not_ad_and_email_is_blank
    assert @topic.valid?
  end

  # def test_published_at_attribute_should_be_protected
  #   assert_raises(ActiveModel::MassAssignmentSecurity::Error) {
  #     Forem::Topic.new(published_at: DateTime.now)
  #   }
  # end
  #
  # def test_ad_confirmation_key_attribute_should_be_protected
  #   assert_raises(ActiveModel::MassAssignmentSecurity::Error) {
  #     Forem::Topic.new(ad_confirmation_key: "key")
  #   }
  # end
  #
  # def test_expired_at_attribute_should_be_protected
  #   assert_raises(ActiveModel::MassAssignmentSecurity::Error) {
  #     Forem::Topic.new(expired_at: DateTime.now)
  #   }
  # end

end

