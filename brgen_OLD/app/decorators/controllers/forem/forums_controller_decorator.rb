Forem::ForumsController.class_eval do
  skip_load_and_authorize_resource

  after_filter :set_timestamp, only: [:index, :show]

  def index
    find_topics

    @sponsored_topics = Forem::Topic.sponsored
  end

  def show
    begin
      @category = Forem::Category.find(params[:id])
      @topics = @category.topics

      render "forem/categories/show" and return
    rescue ActiveRecord::RecordNotFound
      find_forum
      register_view
      build_topic
      find_topics
    end
  end

  # -------------------------------------------------

  def search
    @search = params[:keywords]

    @topics = Forem::Topic.search(@search)
    @topics = @topics.published.by_pinned_or_most_recent_post.page(params[:page]).per(Forem.per_page)
  end

protected
  def forum_params
    params.require(:forum).permit(:notice_page, :forum_type_id)
  end

private
  def find_forum
    begin
      @forum = Forem::Forum.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

  def find_topics
    @topics = @forum ? @forum.topics.not_sponsored : Forem::Topic.not_sponsored

    if sorting_filter == "popular"
      @topics = @topics.send("popular_#{ display_mode }")
    else
      @topics = @forum ? @topics.by_most_recent_post : @topics.send("newsworthy_#{ display_mode }")
    end
    @topics = @topics.published.page(params[:page]).per(Forem.per_page)
  end

  # -------------------------------------------------

  # Set `last_modified` to return `200 OK` or `304 Not Modified`

  # Corresponds to `polling.js`

  # http://goo.gl/T2F6H6

  def set_timestamp
    if @topics.any?
      fresh_when last_modified: @topics.first.published_at
    end
  end
end

