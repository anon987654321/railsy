# -- ADD MAIN CORE FEATURES --

echo "Generating Posts, Communities and Comments..."
bin/rails generate model Main::Community name:string description:text
bin/rails generate model Main::Post title:string content:text user:references community:references
bin/rails generate model Main::Comment content:text user:references post:references
bin/rails db:migrate

cat <<EOF > app/models/main/community.rb
class Main::Community < ApplicationRecord
  has_many :posts, class_name: "Main::Post"

  validates "name", presence: true
end
EOF

cat <<EOF > app/models/main/post.rb
class Main::Post < ApplicationRecord
  belongs_to :user
  belongs_to :community, class_name: "Main::Community"

  has_many :comments, class_name: "Main::Comment"

  validates "title", "content", presence: true
end
EOF

cat <<EOF > app/models/main/comment.rb
class Main::Comment < ApplicationRecord
  belongs_to :post, class_name: "Main::Post"
  belongs_to :user
  validates "content", presence: true
end
EOF

# -- SET UP CONTROLLERS WITH TURBO STREAM SUPPORT --

cat <<EOF > app/controllers/main/posts_controller.rb
class Main::PostsController < ApplicationController
  def create
    @post = Main::Post.new(post_params)
    if @post.save
      respond_to do |format|
        format.html { redirect_to main_community_post_path(@post.community, @post) }
        format.turbo_stream
      end
    else
      render :new
    end
  end

  def update
    @post = Main::Post.find(params[:id])
    if @post.update(post_params)
      respond_to do |format|
        format.html { redirect_to main_community_post_path(@post.community, @post) }
        format.turbo_stream
      end
    else
      render :edit
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :content, :community_id, :user_id)
  end
end
EOF

cat <<EOF > app/controllers/main/comments_controller.rb
class Main::CommentsController < ApplicationController
  def create
    @comment = Main::Comment.new(comment_params)

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to main_community_post_path(@comment.post.community, @comment.post) }
      end
    else
      render :new
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :post_id, :user_id)
  end
end
EOF

# -- SET UP VIEWS WITH TURBO STREAM SUPPORT --

mkdir -p app/views/main/posts app/views/main/comments

cat <<EOF > app/views/main/posts/_post.html.erb
<%= turbo_frame_tag dom_id(post) do %>
  <div class="post" id="post_<%= post.id %>">
    <h2><%= link_to post.title, main_community_post_path(post.community, post) %></h2>
    <p><%= post.content %></p>
  </div>
<% end %>
EOF

cat <<EOF > app/views/main/comments/_comment.html.erb
<%= turbo_frame_tag dom_id(comment) do %>
  <div class="comment" id="comment_<%= comment.id %>">
    <p><%= comment.content %></p>
  </div>
<% end %>
EOF

cat <<EOF > app/views/main/posts/create.turbo_stream.erb
<%= turbo_stream.append "posts", partial: "main/posts/post", locals: { post: @post } %>
EOF

cat <<EOF > app/views/main/posts/update.turbo_stream.erb
<%= turbo_stream.replace @post, partial: "main/posts/post", locals: { post: @post } %>
EOF

cat <<EOF > app/views/main/comments/create.turbo_stream.erb
<%= turbo_stream.append "comments", partial: "main/comments/comment", locals: { comment: @comment } %>
EOF

commit_to_git "Set up dynamic Post, Community and Comment creation with Turbo Streams and StimulusReflex"

# -- ADD FRIENDLYID FOR SEO-FRIENDLY URLs --

bundle add friendly_id

bin/rails generate friendly_id
git add .
git commit -m "Installed FriendlyId for SEO-friendly URLs."

cat <<EOF > app/models/user.rb
class User < ApplicationRecord
  acts_as_tenant(:site)
  belongs_to :site, optional: true

  extend FriendlyId
  friendly_id :username, use: :slugged
end
EOF

cat <<EOF > app/models/main/community.rb
class Main::Community < ApplicationRecord
  has_many :posts, class_name: "Main::Post"

  validates "name", presence: true

  extend FriendlyId
  friendly_id :name, use: :slugged
end
EOF

cat <<EOF > app/models/main/post.rb
class Main::Post < ApplicationRecord
  belongs_to :user
  belongs_to :community, class_name: "Main::Community"

  has_many :comments, class_name: "Main::Comment"

  validates "title", "content", presence: true

  extend FriendlyId
  friendly_id :title, use: :slugged
end
EOF

cat <<EOF > app/models/main/comment.rb
class Main::Comment < ApplicationRecord
  belongs_to :post, class_name: "Main::Post"
  belongs_to :user

  validates "content", presence: true

  extend FriendlyId
  friendly_id :content, use: :slugged
end
EOF

commit_to_git "Set up FriendlyId for SEO-friendly URLs for User, Community, Post, and Comment models."

# -- CONFIGURE I18N AND TRANSLITERATION SUPPORT --

bundle add babosa

cat <<EOF > config/initializers/locale.rb
I18n.available_locales = [:en, :no]
I18n.default_locale = :en

require "babosa"
EOF

commit_to_git "Set up I18n and Babosa for translation and transliteration."

# -- ADD PRIVATE POSTS FEATURE --

echo "Adding private posts feature..."

cat <<EOF > app/models/post.rb
class Post < ApplicationRecord
  belongs_to :user
  has_many :post_visibilities
  has_many :visible_users, through: :post_visibilities, source: :user
  has_many :comments, dependent: :destroy
  has_many :reactions, as: :reactable, dependent: :destroy

  validates :content, presence: true

  after_create :set_expiry
  after_update_commit { broadcast_replace_to "posts" }

  def visible_to?(user)
    self.visible_users.include?(user)
  end

  def set_expiry
    ExpiryJob.set(wait_until: self.expiry_time).perform_later(self.id) if self.expiry_time.present?
  end
end
EOF

cat <<EOF > app/controllers/posts_controller.rb
class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      params[:post][:visible_user_ids].each do |user_id|
        @post.post_visibilities.create(user_id: user_id)
      end
      @post.visible_users.each do |user|
        Notification.create(user: user, post: @post, message: "You have a new private post")
      end
      respond_to do |format|
        format.html { redirect_to @post, notice: t('posts.create.success') }
        format.turbo_stream
      end
    else
      render :new
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:content, :expiry_time, visible_user_ids: [])
  end
end
EOF

cat <<EOF > app/views/posts/new.html.erb
<%= form_with(model: @post, data: { controller: "post", action: "change->post#validate" }) do |form| %>
  <div id="error_explanation">
    <%= render partial: 'shared/errors', locals: { object: @post } %>
  </div>

  <div class="field">
    <%= form.label :content %>
    <%= form.text_area :content, data: { target: "post.content" } %>
  </div>

  <div class="field">
    <%= form.label :expiry_time %>
    <%= form.datetime_select :expiry_time, data: { target: "post.expiryTime" } %>
  </div>

  <div class="field">
    <%= form.label :visible_user_ids, t("posts.visible_to") %>
    <%= form.collection_select :visible_user_ids, User.all, :id, :username, {}, { multiple: true, data: { target: "post.visibleUsers" } } %>
  </div>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
EOF

cat <<EOF > app/views/posts/show.html.erb
<%= turbo_frame_tag dom_id(@post) do %>
  <div class="post" id="post_<%= @post.id %>">
    <p><strong><%= t('posts.content') %>:</strong> <%= @post.content %></p>
    <p><strong><%= t('posts.expires_at') %>:</strong> <%= @post.expiry_time %></p>
    <p><strong><%= t('posts.visible_to') %>:</strong> <%= @post.visible_users.map(&:username).join(", ") %></p>

    <h2><%= t('comments.title') %></h2>
    <div id="comments">
      <%= render @post.comments %>
    </div>

    <%= form_with(model: [@post, Comment.new], data: { controller: "comment", action: "submit->comment#create" }) do |form| %>
      <div class="field">
        <%= form.label :content %>
        <%= form.text_area :content, data: { target: "comment.content" } %>
      </div>
      <div class="actions">
        <%= form.submit t('comments.add') %>
      </div>
    <% end %>
  </div>
<% end %>
EOF

cat <<EOF > app/views/posts/_post.html.erb
<%= turbo_frame_tag dom_id(post) do %>
  <div class="post" id="post_<%= post.id %>">
    <p><strong><%= post.user.username %>:</strong> <%= post.content %></p>
    <div class="reactions">
      <%= render post.reactions %>
    </div>
    <div class="comments">
      <%= render post.comments %>
    </div>
  </div>
<% end %>
EOF

cat <<EOF > app/views/posts/update.turbo_stream.erb
<%= turbo_stream.replace dom_id(@post) do %>
  <%= render @post %>
<% end %>
EOF

cat <<EOF > app/assets/stylesheets/posts.scss
.post {
  border: 1px solid #ddd;
  padding: 15px;
  margin: 10px 0;
  background-color: #f9f9f9;

  .reactions, .comments {
    margin-top: 10px;
  }
}
EOF

cat <<EOF > app/javascript/controllers/post_controller.js
import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["content", "expiryTime", "visibleUsers"]

  connect() {
    console.log("Post controller connected")
  }

  validate() {
    // Add validation logic here
  }
}
EOF

# -- ADD EPHEMERAL CONTENT FEATURE --

echo "Adding ephemeral content feature..."

cat <<EOF > app/models/post.rb
class Post < ApplicationRecord
  belongs_to :user
  has_many :post_visibilities
  has_many :visible_users, through: :post_visibilities, source: :user
  has_many :comments, dependent: :destroy
  has_many :reactions, as: :reactable, dependent: :destroy
  
  validates :content, presence: true

  after_create :set_expiry
  after_update_commit { broadcast_replace_to "posts" }

  def visible_to?(user)
    self.visible_users.include?(user)
  end

  def set_expiry
    ExpiryJob.set(wait_until: self.expiry_time).perform_later(self.id) if self.expiry_time.present?
  end
end
EOF

cat <<EOF > app/jobs/expiry_job.rb
class ExpiryJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    post = Post.find_by(id: post_id)
    post.destroy if post.present?
  end
end
EOF

# -- ADD REAL-TIME COLLABORATION FEATURE --

echo "Adding real-time collaboration feature..."

cat <<EOF > app/channels/posts_channel.rb
class PostsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "posts_#{params[:post_id]}"
  end

  def unsubscribed
    stop_all_streams
  end
end
EOF
