Forem::Category.class_eval do
  acts_as_nested_set

  include Forem::Concerns::Viewable

  validates :value, presence: true

  before_save :set_value_to_downcase

  # -------------------------------------------------

  def self.eager_load_with_forums
    includes(forums: [:forum_type]).where("forem_categories.parent_id IS NULL")
  end

  # -------------------------------------------------

  def posts
    Forem::Post.joins(:topic => :forum).where("forem_forums.category_id = ?", id)
  end

  def topics
    Forem::Topic.joins(:forum).where("forem_forums.category_id = ?", id)
  end

  # -------------------------------------------------

  def expire_ads
    topics.published_by_type(ForumType.ad).where("forem_topics.published_at < ?", Date.today - expires_in).update_all(state: "expired", expired_at: DateTime.now)
  end

  def expire_events
    topics.published_by_type(ForumType.event).where("forem_topics.end_date < ?", Date.today).update_all(state: "expired", expired_at: DateTime.now)
  end

  def expire_regular_posts(page, per_page)
    regular_posts = topics.published_by_type(ForumType.regular)
    regular_posts.order("forem_topics.updated_at DESC").offset(page * per_page).update_all(state: "expired", expired_at: DateTime.now)
  end

  # -------------------------------------------------

  def self.parent_by_forum_type(forum_type_id)
    select("forem_categories.*")
      .joins("join forem_forums on forem_categories.id=forem_forums.category_id")
      .where("forem_forums.forum_type_id='#{ forum_type_id }'")
      .group("forem_categories.id")
  end

  # -------------------------------------------------

  %w(housing for_sale dating events jobs).each do |category_type|
    define_method("#{ category_type }?") { value == category_type }
  end

private
  def set_value_to_downcase
    self.value = self.value.downcase
  end
end

