require 'test_helper'

class Forem::CategoryTests < ActiveSupport::TestCase

  def test_expire_regular_posts_should_expires_regular_posts
    expired = forem_categories(:general).topics.published_by_type(ForumType.regular)

    assert_difference('expired.count', -2) do
      forem_categories(:general).expire_regular_posts(1, 1)
    end
  end

  def test_expire_ads_should_expires_ads
    published = forem_categories(:sell_category).topics.published_by_type(ForumType.ad)

    assert_difference('published.count', -1) do
      forem_categories(:sell_category).expire_ads
    end
  end

  def test_expire_events_should_expires_events
    published = forem_categories(:events_category).topics.published_by_type(ForumType.event)

    assert_difference('published.count', -2) do
      forem_categories(:events_category).expire_events
    end
  end
end

