require "test_helper"

class Forem::PostsControllerTest < ActionController::TestCase
  def test_should_get_new
    get :new, topic_id: forem_topics(:open_topic)
    assert assigns(:reply_to_post).nil?
    assert assigns(:post)
    assert assigns(:post).topic
    assert !assigns(:topic).new_record?
    assert "public", assigns(:post).reply_type
    assert assigns(:post).refer_to_original_post
    assert_template "new"
  end

  def test_should_create_post
    assert_difference "Forem::Post.count" do
      post :create, topic_id: forem_topics(:open_topic), post: { text: "a reply", reply_type: "email", email: "replier@example.com", reply_to_id: forem_topics(:open_topic).posts.first.id }
    end
    assert_redirected_to main_app.forum_topic_path(forem_topics(:open_topic).forum, forem_topics(:open_topic))
  end

  def test_should_not_create_post_if_replies_are_disabled_and_replying_publicly
    assert_no_difference "Forem::Post.count" do
      post :create, topic_id: forem_topics(:private_topic), post: { text: "a reply" }
    end
    assert_template "new"
    assert !assigns(:post).valid?
    assert "#{I18n.t :cant_be_blank}", assigns(:post).errors[:email][0]
  end

  def test_should_not_create_post_if_replying_privately_and_email_is_blank
    assert_no_difference "Forem::Post.count" do
      post :create, topic_id: forem_topics(:private_topic), post: { text: "a reply", reply_type: "email" }
    end
    assert_template "new"
    assert !assigns(:post).valid?
    assert "#{I18n.t :cant_be_blank}", assigns(:post).errors[:email][0]
  end

  def test_should_not_create_post_for_locked_topic
    assert_no_difference "Forem::Post.count" do
      post :create, topic_id: forem_topics(:locked_topic), post: { text: "a reply" }
    end
    assert_redirected_to [forem_topics(:locked_topic).forum, forem_topics(:locked_topic)]
  end

  def test_should_send_email_to_topic_owner_if_someone_reply_to_ad
    assert_difference "Forem::Post.count" do
      post :create, topic_id: forem_topics(:open_topic), post: { text: "this is a reply to ad", reply_to_id: forem_topics(:open_topic).posts.first.id }
    end

    email = ActionMailer::Base.deliveries.last

    assert forem_topics(:open_topic).posts.first.email, email.to[0]
    assert "#{I18n.t :you_have_a_reply} - #{forem_topics(:open_topic).subject}", email.subject
    assert_match(/this is a reply to ad/, email.body.to_s)
  end

  def test_should_render_edit_template_for_post_owner
    sign_in users(:test_user_with_anon_id)
    get :edit, topic_id: forem_topics(:open_topic), id: forem_posts(:reply_to_open_post)
    assert_select "form input" do
      assert_select "[name='post[password]']", 0
    end
    assert_template "edit"
  end

  def test_should_render_password_template_to_edit_post_if_user_is_not_owner
    sign_in users(:test_user_with_anon_id)
    get :edit, topic_id: forem_topics(:open_topic), id: forem_posts(:open_post)
    assert_select "form input" do
      assert_select "[name='password']", 1
    end
    assert_template "password"
  end

  def test_should_render_edit_template_to_if_password_is_correct
    get :edit, topic_id: forem_topics(:open_topic), id: forem_posts(:open_post), password: "password"
    assert_select "form input[type=hidden]" do
      assert_select "[name='post_password']", 1
    end
    assert_template "edit"
  end

  def test_should_render_password_template_password_is_not_correct
    get :edit, topic_id: forem_topics(:open_topic), id: forem_posts(:open_post), password: "incorrect_password"
    assert_template "password"
  end

  def test_should_render_edit_template_with_refer_to_original_if_user_is_editing_other_than_first_post
    sign_in users(:test_user_with_anon_id)
    get :edit, topic_id: forem_topics(:open_topic), id: forem_posts(:reply_to_open_post)
    assert_template "edit"
    assert_select "form input[type=checkbox]" do
      assert_select "[name='post[refer_to_original_post]']", 1
    end
  end

  def test_should_update_post_reply
    sign_in users(:test_user)
    put :update,  topic_id: forem_topics(:open_topic), id: forem_posts(:open_post), post: { text: "updated", email: "open_post_updated@example.com" }
    post = forem_topics(:open_topic).posts.first
    assert post.email, "open_post_updated@example.com"
    assert post.text, "updated"
    assert_redirected_to main_app.forum_topic_path(assigns(:topic).forum, assigns(:topic))
  end

  # def test_should_not_update_post_reply_if_text_is_blank
  #   sign_in users(:test_user)
  #   put :update,  topic_id: forem_topics(:open_topic), id: forem_posts(:open_post), post: { text: "", email: "open_post_updated@example.com" }
  #   assert flash[:alert], I18n.t("forem.post.not_edited")
  #   assert_template "edit"
  # end

  def test_should_not_update_post_reply_if_user_is_not_owner
    sign_in users(:other_user)
    assert_raise ActionController::RoutingError do
      put :update,  topic_id: forem_topics(:open_topic), id: forem_posts(:open_post), post: { text: "updated", email: "open_post_updated@example.com" }
    end
  end

  def test_should_not_update_post_reply_if_user_is_anonymous_and_password_is_not_correct
    assert_raise ActionController::RoutingError do
      put :update,  topic_id: forem_topics(:open_topic), id: forem_posts(:open_post), post: { text: "updated", email: "open_post_updated@example.com" }
    end
  end

  def test_should_update_post_reply_if_user_is_anonymous_and_password_is_correct
    put :update,  topic_id: forem_topics(:open_topic), id: forem_posts(:open_post), post: { text: "updated", email: "open_post_updated@example.com" }, post_password: "password"
    assert_redirected_to main_app.forum_topic_path(assigns(:topic).forum, assigns(:topic))
  end

  def test_should_destroy_post_and_topic_if_topic_has_no_replies_without_asking_password_if_owner
    cookies.permanent[:anonymous_username] = users(:anonymous_user).username
    delete :destroy, topic_id: forem_topics(:anonymous_topic), id: forem_posts(:anonymous_post)
    assert_nil Forem::Topic.where("id=?", assigns(:topic).id).first
    assert_response :success
  end

  def test_should_only_destroy_post_if_topic_has_replies_without_asking_password_if_owner
    cookies.permanent[:anonymous_username] = users(:anonymous_user).username
    delete :destroy, topic_id: forem_topics(:anonymous_topic_with_reply), id: forem_posts(:anonymous_post_with_reply)
    assert_not_nil Forem::Topic.where("id=?", assigns(:topic).id).first
    assert_response :success
  end

  def test_should_render_destroy_template_asking_password_if_user_is_not_owner_or_admin
    cookies.permanent[:anonymous_username] = users(:test_user).username
    delete :destroy, topic_id: forem_topics(:anonymous_topic), id: forem_posts(:anonymous_post)
    assert_select "form"
    assert_template "destroy"
  end

  def test_should_destroy_post_if_password_is_correct_and_redirect_to_forum_expanding_topic_if_it_has_replies
    delete :destroy, topic_id: forem_topics(:anonymous_topic_with_reply), id: forem_posts(:anonymous_post_with_reply), password: "password"
    assert_response :success
  end

  def test_should_destroy_post_and_topic_if_password_is_correct_and_redirect_to_forum_if_topic_has_no_replies
    delete :destroy, topic_id: forem_topics(:anonymous_topic), id: forem_posts(:anonymous_post), password: "password"
    assert_response :success
  end

end

