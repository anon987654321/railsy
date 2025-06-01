require 'test_helper'

class Forem::PostTest < ActiveSupport::TestCase
  def setup
    @post = forem_topics(:open_topic).posts.build
    @post.text = "First forem post"
    @post.email = "user@example.com"
    @post.user = users(:other_user)
  end

  def test_password_is_set_by_default
    post = Forem::Post.new
    assert !post.password.nil?
  end

  def test_generates_random_post_number
    post = Forem::Post.new
    assert !post.no.nil?
  end

  def test_post_is_not_valid_if_replying_privately_and_email_is_blank
    email_reply = forem_topics(:open_topic).posts.build
    email_reply.reply_type = "email"
    assert !email_reply.valid?
  end

  def test_post_is_valid_if_replying_public_and_reply_are_allowed
    reply = forem_topics(:open_topic).posts.build
    assert !reply.valid?
  end

  def test_post_is_not_valid_if_replying_publicly_and_replies_are_disabled_for_parent_topic
    reply = forem_topics(:private_topic).posts.build
    assert !reply.valid?
  end

  def test_post_should_automatically_approved
    @post.save
    assert_equal "approved", @post.state
  end

  def test_encrypts_password_before_creating_post
    assert !@post.password_salt
    assert !@post.password_hash
    @post.save
    assert !@post.password_salt.nil?
    assert !@post.password_hash.nil?
  end

  # TODO: Write tests for subscription

end

