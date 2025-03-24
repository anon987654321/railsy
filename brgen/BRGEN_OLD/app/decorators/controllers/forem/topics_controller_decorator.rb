require "photo_utils"

Forem::TopicsController.class_eval do
  skip_before_action :authenticate_forem_user, :block_spammers

  after_filter :set_timestamp, only: :show

  before_action :find_forum, only: :create
  before_action :find_topic, only: :show

  def show
    register_view(@topic, forem_user)

    @posts = @topic.public_posts
  end

  def new

    # Default

  end

  def create
    @topic = Forem::Topic.new(topic_params)
    @topic.forum = @forum if @forum
    @topic.user = forem_user

    if @topic.save

      # Prepare attachments for photo editing

      PhotoUtils.store_data(params, @topic.posts[0])

      # -------------------------------------------------

      publish_or_confirm!

      # -------------------------------------------------

      if mobile? || !request.xhr?
        redirect_to main_app.forum_topic_path(@topic.forum, @topic), notice: t(:post_created)
      end
    else
      if mobile? || !request.xhr?
        flash.now.alert = t(:post_not_created)
        render "new"
      end
    end
  end

  # -------------------------------------------------

  # TODO: I18n

  def confirm
    @topic = Forem::Topic.find(params[:id])

    if @topic.published?
      redirect_to main_app.forum_topic_path(@topic.forum, @topic), notice: t(:ad_already_confirmed) and return
    end

    if @topic.ad_confirmation_key == params[:key]
      @topic.publish!

      post_to_facebook if forem_user.facebook_user?

      redirect_to main_app.forum_topic_path(@topic.forum, @topic), notice: t(:ad_confirmed)
    end
  end

  # -------------------------------------------------

  # TODO: I18n

  def destroy
    @topic = Forem::Topic.find(params[:id])

    if @topic.owner_or_admin?(forem_user)
      @topic.destroy
      redirect_to [@topic.forum], notice: t(:topic_deleted)
    elsif params[:password]
      @post = @topic.posts.first

      if BCrypt::Engine.hash_secret(params[:password], @post.password_salt) == @post.password_hash
        @topic.destroy
        redirect_to [@topic.forum], notice: t(:topic_deleted)
      else
        flash[:alert] = t(:no_match_please_retry)
      end
    end
  end

# -------------------------------------------------

protected
  def topic_params
    params.require(:topic).permit(:subject, :location, :start_date, :end_date, :price, :size, :facebook_id, :sponsored, :cats_or_dogs, :post_type, posts_attributes: [:text, :reply_type, :email, :password, :enable_comments])
  end

# -------------------------------------------------

private
  def publish_or_confirm!
    if @topic.forum_type == ForumType.ad
      @topic.confirm!
    else
      @topic.publish!
      post_to_facebook if forem_user.facebook_user?
    end
  end

  # -------------------------------------------------

  def post_to_facebook
    Brgen::Facebook.delay.post(forem_user.id, @topic.id, "Forem::Topic", "post", main_app.forum_topic_url(@topic.forum, @topic))
  end

  # -------------------------------------------------

  def find_topic
    @topic = Forem::Topic.find(params[:id])
    not_found if @topic && !@topic.published?
  end

  def find_unpublished_topic
    @topic = Forem::Topic.find(params[:id])
    not_found if @topic && !@topic.approved?
  end

  def find_forum
    params[:forum_id] = params[:forum_id].split('|')[0] if (params[:forum_id].split('|').length == 3)

    begin
      @forum = Forem::Forum.find(params[:forum_id])
    rescue ActiveRecord::RecordNotFound
    end
  end

  # -------------------------------------------------

  # Set `last_modified` to return `200 OK` or `304 Not Modified` upon request

  # Corresponds to `polling.js`

  # http://goo.gl/T2F6H6

  def set_timestamp
    fresh_when last_modified: @topic.posts.last.created_at
  end
end

