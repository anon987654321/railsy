require "test_helper"

class Forem::TopicsControllerTest < ActionController::TestCase

  def test_confirm_should_redirect_to_topic_page
    get :confirm, { id: forem_topics(:pending_confirmation_topic).id, ad_confirmation_key:  "hashkey" }
    assert_equal forem_topics(:pending_confirmation_topic), assigns(:topic)
    assert_redirected_to main_app.forum_topic_path(forem_topics(:pending_confirmation_topic).forum, forem_topics(:pending_confirmation_topic).id)
  end

  def test_should_get_show
    get :show, id: forem_topics(:open_topic)
    assert_template "show"
  end

  def test_show_should_raise_not_found_if_topic_is_not_published
    assert_raises(ActionController::RoutingError) {
      get :show, id: forem_topics(:pending_confirmation_topic)
    }
  end

  def test_should_destroy_topic_user_is_owner
    cookies.permanent[:anonymous_username] = users(:anonymous_user).username
    delete :destroy, id: forem_topics(:anonymous_topic)
    assert_redirected_to assigns(:topic).forum
  end
  #
  def test_should_render_destroy_template_if_user_is_not_owner_of_topic
    cookies.permanent[:anonymous_username] = users(:anonymous_user).username
    delete :destroy, id: forem_topics(:open_topic).id
    assert_template "destroy"
  end

  def test_should_destroy_topic_if_password_is_correct
    cookies.permanent[:anonymous_username] = users(:anonymous_user).username
    delete :destroy, id: forem_topics(:open_topic), password: "password"
    assert_redirected_to assigns(:topic).forum
  end

  def test_should_not_destroy_topic_if_password_is_not_correct
    cookies.permanent[:anonymous_username] = users(:anonymous_user).username
    delete :destroy, id: forem_topics(:open_topic), password: "incorrect_password"
    assert_template "destroy"
  end

end

