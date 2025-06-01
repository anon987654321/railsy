require "photo_utils"

# TODO: I18n

Forem::PostsController.class_eval do
  skip_before_action :authenticate_forem_user, :block_spammers, :find_post_for_topic, :ensure_post_ownership!, :authorize_reply_for_topic!, :authorize_edit_post_for_forum

  def new
    build_reply
  end

  def show
    @post = @topic.public_posts.find(params[:id])
  end

  def create
    @post = @topic.posts.new(post_params)
    @post.user = forem_user
    @post.reply_type = params[:reply_type] if params[:reply_type]
    @reply_to_post = @topic.posts.where("id = ?", params[:post][:reply_to_id]).first

    # TODO: Remove validator on `text` if attachments are present

    if @post.save

      # Prepare photos for editing

      PhotoUtils.store_data(params, @post)

      # -------------------------------------------------

      Brgen::Facebook.delay.post(forem_user.id, @post.id, "Forem::Post", "reply", forem.forum_topic_url(@topic.forum, @topic)) if forem_user.facebook_user?

      # -------------------------------------------------

      @topic.send_ad_forward(@post) if @topic.forum.forum_type == ForumType.ad

      # -------------------------------------------------

      if mobile? || !request.xhr?
        redirect_to main_app.forum_topic_path(@topic.forum, @topic), notice: t(:post_created)
      end
    else
      if mobile? || !request.xhr?
        flash.now.alert = t(:not_created)
        render :new
      end
    end
  end

  def edit
    @post = @topic.public_posts.find(params[:id])

    render "password" if !@post.owner_or_admin?(forem_user) && params[:password].nil?

    if params[:password]
      unless BCrypt::Engine.hash_secret(params[:password], @post.password_salt) == @post.password_hash
        flash.now.alert = t(:passwords_dont_match)
        render "password"
      end
    end
  end

  def update
    @post = Forem::Post.find(params[:id])

    not_found unless (password_correct? || @post.owner_or_admin?(forem_user))

    if @post.update(post_params)
      PhotoUtils.store_data(params, @post)

      # -------------------------------------------------

      redirect_to main_app.forum_topic_path(@topic.forum, @topic), :notice => t('edited', :scope => 'forem.post')
    else
      flash.now.alert = t(:not_edited)
      render :action => "edit"
    end
  end

  def destroy
    @post = @topic.public_posts.find(params[:id])

    if @post.owner_or_admin?(forem_user)
      destroy_post
    elsif params[:password]
      if BCrypt::Engine.hash_secret(params[:password], @post.password_salt) == @post.password_hash
        destroy_post
      else
        flash[:alert] = t(:passwords_dont_match)
      end
    end
  end

protected
  def post_params
    params.require(:post).permit(:text, :password, :facebook_id, :email, :number, :enable_comments, :reply_type, photos_attributes: [])
  end

private
  def find_topic
    @topic = Forem::Topic.find(params[:topic_id])
    not_found unless @topic.published?
  end

  def password_correct?
    params[:post_password] && BCrypt::Engine.hash_secret(params[:post_password], @post.password_salt) == @post.password_hash
  end

  def destroy_post
    @post.destroy
    if @post.topic.posts.count == 0
      delete_post_and_topic_fb
    else
      delete_post_on_fb
    end
  end

  def delete_post_and_topic_fb
    Brgen::Facebook.delay.delete(forem_user.id, @topic.facebook_id) if forem_user.facebook_user?
    @post.topic.destroy
    flash[:notice] = t(:topic_deleted)
  end

  def delete_post_on_fb
    Brgen::Facebook.delay.delete(forem_user.id, @post.facebook_id) if forem_user.facebook_user?
    flash[:notice] = t(:post_deleted)
  end
end

