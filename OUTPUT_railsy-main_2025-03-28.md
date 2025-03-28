## `__shared/@ai.sh`
```
# -- INSTALL AI DEPENDENCIES --

doas pkg_add llvm-16.0.6p8
```

## `__shared/@devise.sh`
```
# -- SET UP DEVISE FOR USER AUTHENTICATION --

if ! psql -U dev -d ${APP}_development -c "SELECT to_regclass('public.users');" | grep -q 'users'; then
  bundle add devise
  bin/rails generate devise:install
  bin/rails generate devise User
  bin/rails db:migrate
  commit_to_git "Added Devise and hooked it up to User model."
else
  echo "Devise users table already exists, skipping migration."
fi

source devise.sh

# -- SET UP OMNIAUTH FOR USER AUTHENTICATION --

bundle add omniauth-openid-connect
bundle add omniauth-google-oauth2
bundle add omniauth-snapchat

mkdir -p app/controllers/users

cat <<EOF > app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def vipps
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Vipps") if is_navigational_format?
    else
      session["devise.vipps_data"] = request.env["omniauth.auth"].except("extra")
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\\n")
    end
  end

  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      session["devise.google_data"] = request.env["omniauth.auth"].except("extra")
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\\n")
    end
  end

  def snapchat
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Snapchat") if is_navigational_format?
    else
      session["devise.snapchat_data"] = request.env["omniauth.auth"].except("extra")
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\\n")
    end
  end
end
EOF

mkdir -p app/models

cat <<EOF > app/models/user.rb
class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[vipps google_oauth2 snapchat]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
    end
  end
end
EOF
commit_to_git "Set up OmniAuth for Vipps, Google, and Snapchat."
```

## `__shared/@falcon.sh`
```
# -- CONFIGURE FALCON AS THE PRIMARY WEB SERVER --

bundle add falcon
bundle add async
bundle add async-redis
bundle add async-websocket

cat <<EOF > config/falcon.rb
#!/usr/bin/env falcon-host
# Falcon for Rails with ActionCable support

ENV["RAILS_ENV"] ||= "production"

require_relative "./config/environment"
require "async/websocket/adapters/rack"

load :rack, :supervisor

Async do
  hostname = "localhost"

  rails = Rack::Builder.new do
    map "/cable" do
      run ActionCable.server
    end

    run Rails.application
  end

  rack hostname do
    endpoint Async::HTTP::Endpoint.parse("http://0.0.0.0:49195")
    app rails
  end

  supervisor
end
EOF
commit_to_git "Set up Falcon as the new web server with Async support"
```

## `__shared/@instant_and_private_message.sh`
```
#!/usr/bin/env zsh
# encoding: utf-8

APP=$1
echo "Setting up instant and private messaging for $APP"

commit_to_git() {
  git add -A
  git commit -m "$1"
  echo "$1"
}

# Generate models, controllers, and views for messaging
bin/rails generate model Message sender:references recipient:references body:text read:boolean
bin/rails generate controller Messages create show index destroy

# Add routes for messages (append to routes.rb)
if ! grep -q "resources :messages" config/routes.rb; then
  echo "resources :messages, only: [:create, :show, :index, :destroy]" >> config/routes.rb
fi

# Create the Messages controller
cat <<EOF > app/controllers/messages_controller.rb
class MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @messages = Message.where(sender: current_user).or(Message.where(recipient: current_user))
  end

  def show
    @message = Message.find(params[:id])
    if @message.recipient == current_user
      @message.update(read: true)
    end
  end

  def create
    @message = Message.new(message_params)
    @message.sender = current_user
    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to messages_path, notice: "Message sent successfully" }
      end
    else
      render :new
    end
  end

  def destroy
    @message = Message.find(params[:id])
    @message.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to messages_path, notice: "Message deleted successfully" }
    end
  end

  private

  def message_params
    params.require(:message).permit(:recipient_id, :body)
  end
end
EOF

# Create the Message model
cat <<EOF > app/models/message.rb
class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  validates :body, presence: true
end
EOF

# Create views for messages
mkdir -p app/views/messages
cat <<EOF > app/views/messages/index.html.erb
<%= tag.h1 "Messages" %>
<%= tag.ul do %>
  <% @messages.each do |message| %>
    <%= tag.li do %>
      <%= link_to message.body.truncate(20), message %>
      <%= message.read ? "(Read)" : "(Unread)" %>
    <% end %>
  <% end %>
<% end %>
<%= turbo_stream_from "messages" %>
EOF

cat <<EOF > app/views/messages/show.html.erb
<%= tag.h1 "Message" %>
<p><strong>From:</strong> <%= @message.sender.email %></p>
<p><strong>To:</strong> <%= @message.recipient.email %></p>
<p><strong>Body:</strong> <%= @message.body %></p>
<p><strong>Read:</strong> <%= @message.read ? "Yes" : "No" %></p>
<%= link_to "Back", messages_path %>
EOF

cat <<EOF > app/views/messages/_form.html.erb
<%= form_with(model: @message, local: true) do |form| %>
  <div class="field">
    <%= form.label :recipient_id %>
    <%= form.collection_select :recipient_id, User.all, :id, :email, prompt: "Select recipient" %>
  </div>
  <div class="field">
    <%= form.label :body %>
    <%= form.text_area :body %>
  </div>
  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
EOF

cat <<EOF > app/views/messages/new.html.erb
<%= tag.h1 "New Message" %>
<%= render "form", message: @message %>
<%= link_to "Back", messages_path %>
EOF

cat <<EOF > app/views/messages/edit.html.erb
<%= tag.h1 "Edit Message" %>
<%= render "form", message: @message %>
<%= link_to "Back", messages_path %>
EOF

# Turbo Streams for creating and destroying messages
cat <<EOF > app/views/messages/create.turbo_stream.erb
<%= turbo_stream.append "messages" do %>
  <%= render @message %>
<% end %>
EOF

cat <<EOF > app/views/messages/destroy.turbo_stream.erb
<%= turbo_stream.remove dom_id(@message) %>
EOF

# Run migrations
bin/rails db:migrate

commit_to_git "Set up instant and private messaging for $APP"
```

## `__shared/@live_cam_streaming.sh`
```
#!/usr/bin/env zsh
# encoding: utf-8

APP=$1
echo "Setting up live cam streaming for $APP"

commit_to_git() {
  git add -A
  git commit -m "$1"
  echo "$1"
}

# Add dependencies
bin/yarn add video.js @rails/actioncable

# Generate models, controllers, and views for live streaming
bin/rails generate model Stream title:string description:text user:references
bin/rails generate controller Streams index show new create destroy

# Add routes for streams (append to routes.rb)
if ! grep -q "resources :streams" config/routes.rb; then
  echo "resources :streams, only: [:index, :show, :new, :create, :destroy]" >> config/routes.rb
fi

# Create the Streams controller
cat <<EOF > app/controllers/streams_controller.rb
class StreamsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_stream, only: [:show, :destroy]

  def index
    @streams = Stream.all
  end

  def show
  end

  def new
    @stream = current_user.streams.build
  end

  def create
    @stream = current_user.streams.build(stream_params)
    if @stream.save
      redirect_to @stream, notice: "Stream created successfully"
    else
      render :new
    end
  end

  def destroy
    @stream.destroy
    redirect_to streams_path, notice: "Stream deleted successfully"
  end

  private

  def set_stream
    @stream = Stream.find(params[:id])
  end

  def stream_params
    params.require(:stream).permit(:title, :description)
  end
end
EOF

# Create the Stream model
cat <<EOF > app/models/stream.rb
class Stream < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
end
EOF

# Create views for streams
mkdir -p app/views/streams
cat <<EOF > app/views/streams/index.html.erb
<%= tag.h1 "Streams" %>
<%= tag.ul do %>
  <% @streams.each do |stream| %>
    <%= tag.li do %>
      <%= link_to stream.title, stream %>
      <p><%= stream.description %></p>
    <% end %>
  <% end %>
<% end %>
EOF

cat <<EOF > app/views/streams/show.html.erb
<%= tag.h1 @stream.title %>
<p><%= @stream.description %></p>
<div id="live-stream" data-controller="stream" data-stream-id="<%= @stream.id %>">
  <video id="live-stream-video" controls autoplay></video>
</div>
<%= link_to "Back", streams_path %>
EOF

cat <<EOF > app/views/streams/_form.html.erb
<%= form_with(model: @stream, local: true) do |form| %>
  <div class="field">
    <%= form.label :title %>
    <%= form.text_field :title %>
  </div>
  <div class="field">
    <%= form.label :description %>
    <%= form.text_area :description %>
  </div>
  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
EOF

cat <<EOF > app/views/streams/new.html.erb
<%= tag.h1 "New Stream" %>
<%= render "form", stream: @stream %>
<%= link_to "Back", streams_path %>
EOF

cat <<EOF > app/views/streams/edit.html.erb
<%= tag.h1 "Edit Stream" %>
<%= render "form", stream: @stream %>
<%= link_to "Back", streams_path %>
EOF

# Create Stimulus controller for live streaming
mkdir -p app/javascript/controllers
cat <<EOF > app/javascript/controllers/stream_controller.js
import { Controller } from "stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["video"]

  connect() {
    this.channel = createConsumer().subscriptions.create(
      { channel: "StreamChannel", stream_id: this.data.get("id") },
      {
        received: data => this.#received(data)
      }
    )
  }

  #received(data) {
    if (data.action === "play") {
      this.videoTarget.src = data.url
    }
  }
}
EOF

# Create StreamChannel
cat <<EOF > app/channels/stream_channel.rb
class StreamChannel < ApplicationCable::Channel
  def subscribed
    stream_from "stream_\#{params[:stream_id]}"
  end
end
EOF

# Create broadcast job
cat <<EOF > app/jobs/stream_broadcast_job.rb
class StreamBroadcastJob < ApplicationJob
  queue_as :default

  def perform(stream, url)
    ActionCable.server.broadcast "stream_\#{stream.id}", action: "play", url: url
  end
end
EOF

# Run migrations
bin/rails db:migrate

commit_to_git "Set up live cam streaming for $APP"
```

## `__shared/@postgresql.sh`
```
#!/bin/zsh

APP=$1

if ! command -v psql &>/dev/null; then
  doas pkg_add postgresql-server
  doas rcctl enable postgresql
fi

if ! doas -u _postgresql pg_ctl status -D /var/postgresql/data &>/dev/null; then
  doas rcctl stop postgresql || true
  doas rm -rf /var/postgresql/data
  doas mkdir /var/postgresql/data
  doas chown _postgresql:_postgresql /var/postgresql/data
  doas -u _postgresql initdb -D /var/postgresql/data -E UTF8
  doas rcctl start postgresql
  sleep 10

  if ! doas -u _postgresql pg_ctl status -D /var/postgresql/data; then
    echo "PostgreSQL failed to start. Exiting..."
    exit 1
  fi

  doas -u _postgresql psql -d postgres -c "CREATE ROLE dev WITH LOGIN SUPERUSER;"
  doas -u _postgresql psql -d postgres -c "CREATE DATABASE ${APP}_development OWNER dev;"
  doas -u _postgresql psql -d postgres -c "CREATE DATABASE ${APP}_test OWNER dev;"
  doas -u _postgresql psql -d postgres -c "CREATE DATABASE ${APP}_production OWNER dev;"

  DB_PASS=$(pwgen 16 1)
  doas -u _postgresql psql -d postgres -c "DROP USER IF EXISTS ${APP}_development;"
  doas -u _postgresql psql -d postgres -c "CREATE USER ${APP}_development WITH LOGIN PASSWORD '${DB_PASS}';"
  echo "local all ${APP}_development scram-sha-256" | doas tee -a /var/postgresql/data/pg_hba.conf
  doas rcctl reload postgresql

  if ! doas -u _postgresql pg_ctl status -D /var/postgresql/data; then
    echo "PostgreSQL failed to start after configuration changes. Exiting..."
    exit 1
  fi
fi

if ! grep -q "permit nopass :wheel as _postgresql" /etc/doas.conf; then
  echo "permit nopass :wheel as _postgresql" | doas tee -a /etc/doas.conf
  commit_to_git "Install and configure PostgreSQL"
else
  echo "Install and configure PostgreSQL"
fi
```

## `__shared/@posts.sh`
```
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
```

## `__shared/@pwa.sh`
```
# -- CONFIGURE RAILS AS A PROGRESSIVE WEB APP --

bin/rails generate pwa:install
commit_to_git "Configured Rails to run as a Progressive Web App (PWA)"
```

## `__shared/@rails_new.sh`
```
gem install bundler --user-install
bundle config set --local path "$HOME/.local"

gem install rails --user-install

# Create and configure the Rails app if it doesn't exist
if [ ! -d "$APP" ]; then
  rails33 new $APP --database=postgresql --javascript=esbuild --css=sass --assets=propshaft
  cd $APP
  git init
  bundle install
  yarn install
  commit_to_git "Initial commit: Generate Rails app with PostgreSQL, Esbuild, SASS, and Propshaft."
else
  cd $APP
fi
```

## `__shared/@redis.sh`
```
# -- ENSURE REDIS IS INSTALLED AND RUNNING --

if ! command -v redis-server &>/dev/null; then
  doas pkg_add redis
  doas rcctl enable redis
fi
doas rcctl start redis
echo "Ensure Redis is installed and running"
```

## `__shared/@upload_images.sh`
```
# -- SET UP ACTIVE STORAGE AND IMAGE PROCESSING --

if ! psql -U dev -d ${APP}_development -c "SELECT to_regclass('public.active_storage_blobs');" | grep -q 'active_storage_blobs'; then
  bin/rails active_storage:install
  bin/rails db:migrate
  bundle add image_processing
  commit_to_git "Set up Active Storage and ImageProcessing."
else
  echo "Active Storage tables already exist, skipping migration."
fi
```

## `__shared/@yarn.sh`
```
# -- INSTALL YARN --

if ! command -v yarn &>/dev/null; then
  doas npm install yarn -g
fi
echo "Ensure Yarn is installed"
```

## `amber/amber.sh`
```
#!/bin/zsh
set -e

# amber.sh - Sets up "Amber", an AI-enhanced social network for fashion.
#
# Features: wardrobe management, style assistance, a Medium-like rich text editor,
# infinite scroll, live search, Stripe integration, and social interactions.

APP_NAME="amber"
BASE_DIR="$HOME/dev/rails_apps"

source "$BASE_DIR/__shared.sh"

log "Starting Amber setup (AI-based fashion network)"

initialize_setup "$APP_NAME"
setup_yarn
create_rails_app "$APP_NAME"

cd "$APP_NAME"

install_common_gems
setup_devise
setup_frontend
setup_active_storage
generate_social_models
setup_stripe
setup_mediumstyle_editor
setup_mapbox
setup_common_scss
setup_infinite_scroll
setup_live_search

bin/rails db:migrate

log "Generating WardrobeItem model for clothing management"
bin/rails generate model WardrobeItem name:string color:string size:string description:text user:references || error_exit "WardrobeItem model creation failed"
bin/rails db:migrate

setup_social_seed_data "$APP_NAME"

commit_to_git "Amber is fully set up (AI-enhanced fashion network)."
echo "Amber setup complete. Run 'bin/rails server' to start local development."

# End of amber.sh

```

## `amber/amber_README.md`
```
# Amber

Amber is an AI-enhanced social network for fashion that allows users to organize and visualize their wardrobe, get style assistance, mix and match outfits, and stay updated with the latest fashion trends.

## Features

- **Visualize Your Wardrobe**: Snap pictures of your clothes; Amber organizes them efficiently.
- **Style Assistant**: Get daily outfit suggestions that make you look your best.
- **Mix & Match Magic**: See new outfit combinations with a tap of a button.
- **Fashion Feed**: Stay updated with the latest trends and runway looks.
- **Shop Smarter**: Find clothes that match items you already own.
- **Live Chat**: Chat with other users in real-time.
- **Live Webcam Streaming**: Stream your outfits live using your webcam.
- **Public Chatroom**: Participate in public discussions with other users.
- **Wardrobe Analytics**: Track usage, cost-per-wear, and underutilized items.
- **Closet Organization**: Tips for cleaning, organizing, and storing your wardrobe.

## Setup

1. **Install dependencies**: `bundle install`
2. **Set up the database**: `bin/rails db:setup`
3. **Start the server**: `bin/rails server`
4. **Have fun!**: Visit `http://localhost:3000` to see Amber in action.

## Future Plans

1. **Virtual Fitting Room**: Try on outfits digitally.
2. **Mood Matcher**: Outfit ideas based on your emotions.
3. **Event Planner**: Choose outfits for scheduled events.
4. **Sustainable Styles**: Eco-friendly fashion recommendations.
5. **Repair and Recycle**: Suggestions for giving new life to old clothes.
6. **Global Trends**: Insights from international fashion hubs.
7. **Local Designer Highlights**: Discover local fashion talents.
8. **Fashion Insights**: Learn from your style preferences.
9. **Online Shopping Assistance**: Intelligent shopping help.
10. **Community Feedback**: Share and receive outfit feedback.
11. **Fashion Challenges**: Participate in style competitions.
12. **DIY Fashion Tips**: Create your own clothes.
13. **Celebrity Inspiration**: Get the celebrity look.
14. **Weather-Based Suggestions**: Dress appropriately for the weather.
15. **Clothing Health Tips**: Advice on fabric care.
16. **Inclusive Fashion**: Personalized style for all body types.
17. **Runway Analysis**: Detailed reviews of fashion shows.
18. **Fashion History**: Explore vintage and historical styles.
19. **Fabric Design Assistance**: Create custom patterns.
20. **Efficient Wardrobe Management**: Optimize and declutter your closet.
21. **Travel Planning**: Create and manage packing lists.
22. **Inspiration Library**: Save and organize style inspirations.
23. **Care Instructions**: Maintain your clothing with personalized care tips.

```

## `amber/amber_README2.md`
```
# Amber: Your Personal Digital Closet 👗👠👜

Amber is an innovative wardrobe organizer app 📱🛍️ designed to help you manage your clothing items 👗👚 and outfits 👗👖 in a fun 🎉, engaging way. Whether you want to keep track of what you own 👀, create amazing outfits 🌟, or simply organize your wardrobe 🗂️, Amber makes it easy and enjoyable 😄. Inspired by modern fashion apps 👗📲 and optimized for a pleasant user experience 😊, Amber is perfect for a female audience 👩 looking for a stylish and streamlined wardrobe management tool 💅.

## Features 🚀

- **Clothing Items Management** 👗: Add ➕, edit ✏️, and remove ❌ your clothing items effortlessly, including details like name 🏷️, category 🏷️, color 🎨, size 📏, and material 🧵.
- **Outfit Creation** 👗👚: Mix and match 🔀 your clothing items to create stunning outfits ✨. Save 💾 and organize them for different occasions 🎉.
- **Carousel Display** 🎠: Browse your clothing items 👗 and outfits 👚 with an interactive image carousel 📸, powered by Swiper.js and Stimulus ⚡.
- **Lightbox Gallery** 🔍🖼️: View high-resolution images 📸 of your outfits in an elegant lightbox gallery 🖼️ using LightGallery.js.
- **Mobile-First PWA** 📱✨: Amber is built as a mobile-first Progressive Web App 📲, ensuring a smooth experience 🧈 on mobile devices 📞.

## Tech Stack 🛠️

- **Ruby on Rails** 💎🚄: The backend framework used to manage the application's functionality ⚙️ and structure 🏗️.
- **PostgreSQL** 🐘: The database used to store information 💾 about your clothing items 👗 and outfits 👚.
- **Hotwire (Turbo + Stimulus)** ⚡: Enables a modern 💻, reactive user interface 🎨 without writing much JavaScript ✍️.
- **Stimulus Components** ⚙️: Used for creating the carousel 🎠, along with Swiper.js for smooth navigation 🎢.
- **LightGallery.js** 🖼️: Integrated for viewing outfit photos 👚 in a lightbox gallery 🖼️.
- **Packery.js** 📦: Manages the layout 🗺️ of image galleries 📸 in an engaging and easy-to-navigate manner 📜.
- **SCSS** 🎨: Custom styles to ensure Amber looks great 👗 and feels intuitive to use 👍.

## Installation ⚙️

To get started with Amber, follow these steps 🪜:

1. **Clone the Repository** 🌀

   ```bash
   git clone <repository-url>
   cd amber
   ```

2. **Install Dependencies** 📦 Make sure you have `Ruby` 💎 and `Node.js` installed 💻.

   ```bash
   bundle install
   yarn install
   ```

3. **Set Up the Database** 🐘

   ```bash
   rails db:create db:migrate db:seed
   ```

4. **Run the Application** 🚀

   ```bash
   rails server
   ```

   Visit `http://localhost:3000` in your browser 🌐 to view the app.

## Usage 🎮

- **Home Page** 🏠: Get an overview 🔍 of your digital closet 👗. Navigate through clothing items 👚 and outfits 🎽 using the carousel 🎠 for an interactive experience 🌀.
- **Add Clothing Items** ➕👗: Click on "Add New Clothing Item" 🖱️ to add new pieces 🆕 to your wardrobe 👗, including details like name, category, and material 🏷️.
- **Create Outfits** ✨👚: Combine clothing items into outfits 👗. Keep track 📝 of your favorite looks 🌟 for specific occasions 🎊.
- **View Your Gallery** 🖼️: View high-resolution images 📸 of your clothing items 👗 and outfits 👚 in a lightbox gallery 🖼️ for a detailed look 👀.

## Contributing 🤝

We welcome contributions 🛠️ to improve Amber ✨. Feel free to open an issue ⚠️ or submit a pull request 📥.

## About Us 👫

Conceived as the brainchild 🧠💡 of Ragnhild Laupsa Mæhle 👩 and Johnnyboy Dr. Tepstad 👨‍⚕️, Amber was created for individuals 👗 who want to stay stylish 💃 while keeping their wardrobe organized 🗂️. Our goal 🏆 is to make fashion management easy 😌, fun 🎉, and accessible for everyone 👥. We are committed to providing a pleasant 😊 and wholesome 🫶 user experience, leveraging the latest technologies 💻 to make wardrobe organization as delightful as possible 🌸.

## License 📜

Amber is open-source 🔓 and distributed under the MIT License 📄.

```

## `brgen/brgen.sh`
```
#!/bin/zsh

APP_NAME="brgen"
BASE_DIR="$HOME/dev/rails_apps"

# Create application directory
mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

# -- LOAD SHARED FUNCTIONALITY --
source "$BASE_DIR/__shared.sh"

# -- INITIAL SETUP --
setup_postgresql "$APP_NAME"
setup_redis
setup_yarn
create_rails_app "$APP_NAME"

cd "$APP_NAME"

# -- FEATURE IMPLEMENTATION --

# Active Storage and Image Processing
setup_active_storage

# Authentication (Devise + OmniAuth)
setup_devise
setup_omniauth "google_oauth2 snapchat"

# Real-time Features (ActionCable + StimulusReflex)
setup_falcon
setup_action_cable
setup_stimulus_reflex

# PWA Configuration
setup_pwa

# Core Models and Features
generate_social_models

# Run Migrations
bin/rails db:migrate

# Controllers and Views
bin/rails generate controller Posts index show new create edit update destroy stories
bin/rails generate controller Comments create destroy
bin/rails generate controller Communities index show new create edit update destroy discover
bin/rails generate controller Categories index show new create edit update destroy
bin/rails generate controller Messages create destroy
bin/rails generate controller Notifications index update
bin/rails generate controller Reactions create
bin/rails generate controller Users show edit update dashboard

# SCSS Styling
setup_common_scss

# Infinite Scroll
setup_infinite_scroll

# Live Search
setup_live_search

# Seed Database
setup_social_seed_data "$APP_NAME"

# Git Commit
commit_to_git "Complete setup for Brgen as a Reddit/Craigslist/X/TikTok/Snapchat clone."

# Final Message
echo "Setup complete. Start the Rails server with 'bin/rails server'."

```

## `brgen/brgen_README.md`
```
# brgen

### brgen.no, oshlo.no, trndheim.no, stvanger.no, trmso.no, longyearbyn.no, reykjavk.is, kobenhvn.dk, stholm.se, gtebrg.se, mlmoe.se, hlsinki.fi, lndon.uk, cardff.uk, mnchester.uk, brmingham.uk, lverpool.uk, edinbrgh.uk, glasgw.uk, amstrdam.nl, rottrdam.nl, utrcht.nl, brssels.be, zrich.ch, lchtenstein.li, frankfrt.de, wrsawa.pl, gdnsk.pl, brdeaux.fr, mrseille.fr, mlan.it, lsbon.pt, lsangeles.com, newyrk.us, chcago.us, houstn.us, dllas.us, austn.us, prtland.com, mnneapolis.com

**Brgen** redefines the concept of a social network, leveraging AI to create a hyper-localized platform tailored to major cities around the globe. More than just a social hub, Brgen seamlessly integrates multiple sub-applications, including:

- **Online Marketplace**: A platform for local buying and selling.
- **Dating Service**: A hyper-localized dating experience.
- **Music Sharing Platform**: Share, discover, and collaborate on music.
- **Record Label**: Promote local talent.
- **Television Channel**: Hyper-local TV content tailored to each city.
- **Street Food Delivery**: Connect with local street food vendors.

### Cities Supported

Brgen operates in a growing list of major cities, including:

- **Nordic Region**:

  - **Norway**: Bergen (brgen.no), Oslo (oshlo.no), Trondheim (trndheim.no), Stavanger (stvanger.no), Tromsø (trmso.no), Longyearbyen (longyearbyn.no)
  - **Iceland**: Reykjavik (reykjavk.is)
  - **Denmark**: Copenhagen (kobenhvn.dk)
  - **Sweden**: Stockholm (stholm.se), Gothenburg (gtebrg.se), Malmö (mlmoe.se)
  - **Finland**: Helsinki (hlsinki.fi)

- **United Kingdom**:

  - **England**: London (lndon.uk), Manchester (mnchester.uk), Birmingham (brmingham.uk), Liverpool (lverpool.uk)
  - **Wales**: Cardiff (cardff.uk)
  - **Scotland**: Edinburgh (edinbrgh.uk), Glasgow (glasgw.uk)

- **Other European Cities**:

  - **Netherlands**: Amsterdam (amstrdam.nl), Rotterdam (rottrdam.nl), Utrecht (utrcht.nl)
  - **Belgium**: Brussels (brssels.be)
  - **Switzerland**: Zurich (zrich.ch)
  - **Liechtenstein**: Vaduz (lchtenstein.li)
  - **Germany**: Frankfurt (frankfrt.de)
  - **Poland**: Warsaw (wrsawa.pl), Gdansk (gdnsk.pl)
  - **France**: Bordeaux (brdeaux.fr), Marseille (mrseille.fr)
  - **Italy**: Milan (mlan.it)
  - **Portugal**: Lisbon (lsbon.pt)

- **United States**:

  - **California**: Los Angeles (lsangeles.com)
  - **New York**: New York City (newyrk.us)
  - **Illinois**: Chicago (chcago.us)
  - **Texas**: Houston (houstn.us), Dallas (dllas.us), Austin (austn.us)
  - **Oregon**: Portland (prtland.com)
  - **Minnesota**: Minneapolis (mnneapolis.com)

### Monetization Strategies

Brgen harnesses sophisticated monetization strategies, including:

- **SEO Strategies**: Leveraging search engine optimization for visibility.
- **Pay-per-click Advertising**: Generating revenue through targeted ads.
- **Affiliate Marketing**: Partnering with local and global brands.
- **Subscription Models**: Offering premium features for users.

### Key Features

- **Hyper-localized Content**: Custom content for each city.
- **AI-driven Insights**: Personalized user experience using advanced AI models.
- **Integrated Services**: All services are tightly integrated, providing a seamless user experience.

### Summary

Brgen is designed to bring communities together, making each city feel like a closely-knit hub. It leverages AI and innovative monetization strategies to support local businesses and provide a unique social experience.

```

## `brgen/dating/brgen_dating.sh`
```
#!/usr/bin/env zsh

app_name="brgen_dating"
source __shared.sh

# ---

initialize_app_directory() {
  initialize_setup "$app_name"
  log "Initialized $app_name directory"
}

# ---

setup_frontend_with_rails() {
  log "Setting up front-end for $app_name"

  create_rails_app "$app_name"
  if ! bin/rails db:migrate; then
    error_exit "DB migration failed for $app_name"
  fi
  log "Rails setup completed for $app_name"

  generate_view_and_scss "brgen_dating/profiles/index" "<h1>Profiles</h1><button>Browse Profiles</button>" "h1 { font-size: 2rem; } button { background-color: #ff69b4; color: white; padding: 10px; border-radius: 5px; }"
  generate_view_and_scss "brgen_dating/matches/index" "<h1>Your Matches</h1><button>See Your Matches</button>" "h1 { font-size: 2rem; } button { background-color: #ff69b4; color: white; padding: 10px; border-radius: 5px; }"
  log "Frontend views setup for $app_name"

  yarn_install "swiper@8.0.7" "@stimulus-components/carousel@1.2.0" "@hotwired/turbo-rails@7.2.0"
  log "JavaScript components setup completed"
}

# ---

setup_app_specific() {
  log "Setting up specifics for $app_name"

  generate_model_with_validations "BrgenDating::Profile" "name:string age:integer location:string bio:text user_id:integer" "validates :name, presence: true
validates :age, numericality: { greater_than: 18 }" "belongs_to :user"
  generate_model_with_validations "BrgenDating::Match" "profile_id:integer matched_profile_id:integer status:string" "validates :status, presence: true" "belongs_to :profile"
  log "Models generated for $app_name"

  generate_controller_with_crud "BrgenDating::Profiles" "BrgenDating::Profile" "name age location bio user_id"
  generate_controller_with_crud "BrgenDating::Matches" "BrgenDating::Match" "profile_id matched_profile_id status"
  log "Controllers generated for $app_name"

  setup_redis || error_exit "Redis setup failed"
  if ! redis-cli ping | grep -q PONG; then
    error_exit "Redis health check failed"
  fi
  log "Redis setup completed"

  integrate_live_chat || error_exit "Live chat integration failed"
  configure_live_chat_backend || error_exit "Live chat backend configuration failed"
  log "Live chat setup completed"

  apply_common_features "$app_name"
  log "$app_name specifics setup completed"
}

# ---

seed_database() {
  log "Seeding database for $app_name"
  bin/rails db:seed || error_exit "Database seeding failed for $app_name"
  log "Database seeding completed for $app_name"
}

# ---

main() {
  log "Starting $app_name setup"
  initialize_app_directory
  setup_frontend_with_rails
  setup_app_specific
  seed_database
  log "$app_name setup finished"
}

main "$@"

```

## `brgen/dating/brgen_dating_README.md`
```
# Brgen Dating Service

**Brgen Dating** is a hyper-localized dating experience, designed to connect individuals within the same community and facilitate meaningful relationships. By leveraging AI, Brgen Dating customizes match recommendations to provide a unique and highly personalized experience.

### Key Features

- **AI-driven Matchmaking**: Personalized recommendations based on user preferences and local data.
- **Community Focus**: Connect with people in your city, making dating more meaningful and context-aware.
- **Event Integration**: Attend local events and meet-ups tailored to bring the community together.
- **Privacy First**: Secure data handling and privacy settings that allow users to control their visibility.

### Target Audience

- **Local Residents**: Individuals looking to meet others in the same city or nearby regions.
- **Event Enthusiasts**: People interested in local gatherings and community events.
- **Privacy-Conscious Users**: Users who value control over their data and privacy.

### Monetization Strategies

- **Premium Membership**: Offering features such as advanced filtering and priority access to events.
- **In-app Purchases**: Boost visibility and connect with more users through paid promotions.
- **Event Ticket Sales**: Generate revenue by organizing and promoting local events.

### Summary

Brgen Dating offers a refreshing, hyper-localized approach to dating, focusing on community integration and meaningful relationships. It combines AI-driven matchmaking with event-based interactions, providing a seamless and enjoyable experience for users.

```

## `brgen/dating/dating.rake`
```
# frozen_string_literal: true

require "replicate"
require "faker"

namespace :faker do
  task dating: :environment do
    scraper = Dating::Scraper.new
    scraper.run
  end
end

module Dating
  class Scraper
    ACTIVITY = [
      "looking at the camera",
      "attempting to set a new world record",
      "recreating a scene from a favorite movie",
      "attempting to cook a gourmet meal with random pantry items",
      "building a pillow fort",
      "starting a dance-off in the living room",
      "holding a karaoke competition",
      "learning a magic trick",
      "conducting a DIY science experiment",
      "participating in a home fashion show",
      "hosting a virtual game night",
      "trying to speak a new language",
      "making a homemade music video",
      "attempting a world record for the most cups of coffee consumed in a day",
      "inventing a new type of dance",
      "trying to make their pet internet-famous"
    ].freeze

    def outfit_based_on_gender(gender)
      if gender == "male"
        [
          "streetwear: baggy jeans, oversized graphic tee, and chunky sneakers",
          "luxury casual: designer sweatpants, high-end logo t-shirt, and limited-edition sneakers",
          "edgy: leather pants, graphic tank top, layered chain necklaces, and combat boots",
          "flashy: colorful suit, diamond-encrusted watch, and patent leather loafers",
          "athleisure: branded tracksuit, matching cap, and sporty sneakers",
          "minimalist: black slim-fit jeans, plain white tee, and black leather high-tops",
          "vintage: retro sports jersey, baggy denim jeans, and classic basketball shoes"
        ]
      else
        [
          "edgy: black leather mini skirt, studded crop top, and knee-high boots",
          "glam: sequin jumpsuit, silver stiletto heels, and oversized sunglasses",
          "punk: ripped black jeans, band t-shirt, leather jacket, and combat boots",
          "retro: polka dot midi dress, red patent heels, and cat-eye sunglasses",
          "festival: neon fringe crop top, denim cutoff shorts, and glitter ankle boots",
          "avant-garde: deconstructed blazer, asymmetric skirt, and platform shoes",
          "streetwear: oversized graphic sweatshirt, bike shorts, and chunky sneakers"
        ]
      end.sample
    end

    # Popular techniques in award-winning cinematography
    # https://stable-diffusion-art.com/realistic-people/#Lighting_keywords
    LIGHTING = [
      "three-point lighting",
      "high-key lighting",
      "low-key lighting",
      "chiaroscuro lighting",
      "motivated lighting",
      "natural lighting",
      "practical lighting",
      "backlighting",
      "side lighting",
      "fill lighting"
    ].freeze

    def initialize
      Replicate.configure do |config|
        config.api_token = ENV["REPLICATE_API_KEY"]
      end
    end

    def run
      model = Replicate.client.retrieve_model("mcai/realistic-vision-v2.0")
      version = model.latest_version

      4.times do
        gender = %w[male female].sample

        user = User.create!(
          email: Faker::Internet.email,
          password: Faker::Internet.password(min_length: 8, mix_case: true, special_characters: true),
          first_name: gender == "male" ? Faker::Name.male_first_name : Faker::Name.female_first_name,
          bio: Faker::ChuckNorris.fact,
          age: rand(16..80),
          gender: gender == "male" ? 1 : 0,
          seeking_gender: gender == "male" ? 0 : 1
        )

        inputs = {
          "prompt": "photo of norwegian #{ gender } #{ ACTIVITY.sample }, #{ ['blonde', 'dark blonde', 'brown', 'black', 'red'].sample } hair, wearing #{ outfit_based_on_gender(gender) }, #{ LIGHTING.sample }, DSLR, ultra quality, sharp focus, tack sharp, DOF, film grain, Fujifilm XT3, crystal clear, 8K UHD, highly detailed glossy eyes, high detailed skin, skin pores",
          "negative_prompt": "disfigured, ugly, bad, immature, cartoon, anime, 3d, painting, b&w, nude",
          "width": 512,
          "height": 768,
          "num_outputs": rand(1..4),
          "num_inference_steps": 50,
          "guidance_scale": 7,
          "scheduler": "EulerAncestralDiscrete"
        }

        prediction = version.predict(inputs)
        fetch_prediction(prediction)

        url = prediction.urls["get"]
        add_photo(url, user, "avatar")
        puts url

        sleep 12
      end
    end

    def fetch_prediction(prediction)
      loop do
        prediction.refetch
        break if prediction.finished?

        puts "Sleeping 30 seconds while waiting for image..."
        sleep 30
      end
    end

    def add_photo(url, resource, attachment_type)
      file = URI.open(url, "Authorization" => "Token #{ Replicate.api_token }")
      filename = File.basename(URI.parse(url).path)
      resource.__send__(attachment_type).attach(io: file, filename:)
      resource.save!
    end
  end
end
```

## `brgen/dating/dating.sh`
```
#!/usr/bin/env zsh
set -e # Halt script execution on first error

echo "Configuring BRGEN Dating features within the existing BRGEN Rails application..."

# Navigate to the main directory of your BRGEN Rails application
cd /path/to/brgen

## Setup basic Dating models
echo "Generating basic models for the Dating namespace..."
bin/rails generate model Dating::Profile user:references bio:text interests:text
bin/rails generate model Dating::Like user:references liked_user:references
bin/rails generate model Dating::Dislike user:references disliked_user:references
bin/rails db:migrate

git add .
git commit -m "Setup basic Dating models (Profile, Like, Dislike)"

## Implement matchmaking logic
echo "Adding matchmaking service logic..."
mkdir -p app/services/dating
cat <<RUBY > app/services/dating/matchmaking_service.rb
module Dating
  class MatchmakingService
    def self.find_matches(user)
      likes_given = user.likes.pluck(:liked_user_id)
      likes_received = Dating::Like.where(liked_user_id: user.id).pluck(:user_id)
      matches = likes_given & likes_received
      matches.each do |match_id|
        user.matches.find_or_create_by(matched_user_id: match_id)
      end
    end
  end
end
RUBY

git add .
git commit -m "Implemented matchmaking logic"

## Implementing Controllers for Profiles
echo "Creating controllers for profile interactions..."
mkdir -p app/controllers/dating
cat <<RUBY > app/controllers/dating/profiles_controller.rb
module Dating
  class ProfilesController < ApplicationController
    before_action :set_profile, only: [:show, :edit, :update]

    def index
      @profiles = Profile.all
    end

    def show
    end

    private

    def set_profile
      @profile = Profile.find(params[:id])
    end
  end
end
RUBY

git add .
git commit -m "Added basic controllers for Dating profiles"

## Enhancing Interactions with Hotwire and Stimulus
echo "Enhancing Profile interactions using Hotwire and Stimulus..."
yarn add @hotwired/stimulus @hotwired/turbo-rails

cat <<JS > app/javascript/controllers/dating_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  like() {
    const profileId = this.element.dataset.profileId;
    fetch(\`/dating/profiles/\${profileId}/like\`, { method: 'POST' })
      .then(response => response.text())
      .then(html => this.element.outerHTML = html);
  }

  dislike() {
    const profileId = this.element.dataset.profileId;
    fetch(\`/dating/profiles/\${profileId}/dislike\`, { method: 'POST' })
      .then(response => response.text())
      .then(html => this.element.outerHTML = html);
  }
}
JS

git add .
git commit -m "Enhanced Profile interactions with Stimulus controllers for like and dislike actions"

## Setup Turbo Streams and Views for Dynamic Profile Updates
echo "Setting up views with Turbo Streams for dynamic profile interactions..."
mkdir -p app/views/dating/profiles
cat <<ERB > app/views/dating/profiles/index.html.erb
<%= turbo_stream_from "dating" %>
<div data-controller="dating">
  <% @profiles.each do |profile| %>
    <div class="profile-card" data-profile-id="<%= profile.id %>" data-action="mouseover->profile#highlight">
      <%= image_tag profile.user.avatar.url, alt: profile.user.username %>
      <h3><%= profile.user.username %>, <%= profile.user.age %></h3>
      <p><%= profile.bio %></p>
      <button data-action="dating#like">Like</button>
      <button data-action="dating#dislike">Dislike</button>
    </div>
  <% end %>
</div>
ERB

git add .
git commit -m "Implemented Turbo Streams in Dating views for dynamic profile updates"

echo "BRGEN Dating subapp enhancements complete. Ready for interactive, real-time user engagement."
```

## `brgen/marketplace/amazon.rake`
```
# frozen_string_literal: true

require "ferrum"
require "open-uri"
require "addressable/uri"
# require "tesseract-ocr"
# require "pry"

AFFILIATE_ID = "brgen0a-20"

INFLUENCERS = [
  {
    url: "https://amazon.com/shop/mik.zenon",
    country: "United States"
  }, {
    url: "https://amazon.com/shop/theohiogirljaz",
    country: "United States"
  }, {
    url: "https://amazon.co.uk/shop/mik.zenon",
    country: "United Kingdom"
  }
]

namespace :scrape do
  task amazon: :environment do
    class Scraper
      def get_seller_lists(url)
        $browser = Ferrum::Browser.new(
          base_url: "https://#{ Addressable::URI.parse(url).domain }",
          slowmo: 2,
          timeout: 60,
          process_timeout: 30
          # Ferrum::TimeoutError
          # Ferrum::ProcessTimeoutError
        )

        $useragent = USERAGENTS.sample
        $browser.headers.set("User-Agent" => $useragent)

        $browser.go_to(url)
        puts $browser.current_url
        humanize
        # scroll_to_bottom

        $browser.at_css(".list-container").css(".a-link-normal").each do |list|
          list_url = list.attribute("href")

          get_product_links(list_url)
        end
      end

      def get_product_links(list_url)
        $browser.go_to(list_url)
        puts $browser.current_url
        humanize
        # scroll_to_bottom

        product_paths = []

        $browser.at_css("#list-item-container").css(".single-list-item > a").each do |product|
          product_path = product.attribute("href")

          product_paths << product_path
        end

        # Remove duplicates
        # product_paths = product_paths.uniq

        puts product_paths
        scrape_and_create_products(product_paths)
      end

      def scrape_and_create_products(product_paths)
        product_paths.each do |product_path|
          $browser.go_to(product_path)
          puts $browser.current_url
          humanize
          # scroll_to_bottom

          # Go to next product
          if $browser.at_css("#outOfStock").present?
            puts "Out of stock, skipping..."
            next
          end

          # Turn breadcrumbs into taxons
          taxonomy = Spree::Taxonomy.find_or_create_by!(name: "Main")

          taxon_ids = []
          taxons = $browser.at_css(".a-breadcrumb")
          if taxons.present?
            taxons.css(".a-link-normal").each do |taxon|
              taxon = taxon.text.strip

              created_taxon = Spree::Taxon.find_or_create_by!(
                name: taxon,
                taxonomy:
              )
              puts created_taxon.name

              taxon_ids << created_taxon.id
            end
          else
            puts "No taxons, skipping..."
            next
          end

          # Stock samples

          Spree::Sample.load_sample("shipping_categories")
          Spree::Sample.load_sample("tax_categories")

          shipping_category = Spree::ShippingCategory.find_by_name!("Default")
          tax_category = Spree::TaxCategory.find_by_name!("Default")

          # Options and variants

          values = []

          def set_options(type, value, values)
            created_type = Spree::OptionType.find_by_name(type)
            unless created_type.present?
              created_type = Spree::OptionType.create!(
                name: type,
                presentation: type
              )
              puts "Created OptionType: #{ created_type.name }"
            end

            created_value = Spree::OptionValue.find_by_name(value)
            return if created_value.present?

            created_value = Spree::OptionValue.create!(
              name: value,
              presentation: value,
              option_type: created_type
            )
            puts "Created OptionType for #{ created_type.name }: #{ created_value.name }"

            # Write to array for product creation later on
            values << created_value
          end

          options_table = $browser.at_css("#productOverview_feature_div table")
          if options_table.present?
            options_table.css("tr").each do |row|
              type = row.at_css("td:nth-of-type(1) span").text.strip
              value = row.at_css("td:nth-of-type(2) span").text.strip

              set_options(type, value, values)
            end
          else
            puts "No options, skipping..."
          end

          # options_form = $browser.at_css("#twister_feature_div form")
          # if options_form.present?
          #   options_form.css(".a-row").each do |row|
          #     type = row.at_css(".a-form-label").text.strip.gsub!(/[^0-9A-Za-z]/, "")
          #     value = row.at_css(".selection").text.strip
          #
          #     set_options(type, value, values)
          #   end
          # end

          name = $browser.at_css("#title span").text.strip

          # Remove everything after commas, dashes, slashes and pipes
          name = name.sub(/,.*/, "")
          name = name.sub(/ - .*/, "")
          name = name.sub(%r{./ .*}, "")
          name = name.sub(/.\| .*/, "")

          price = $browser.at_css(".a-price .a-offscreen")
          if price.present?
            price = price.text.strip
          else
            puts "No price, skipping..."
          end

          description = []
          $browser.at_css("#feature-bullets").css("li:not(#replacementPartsFitmentBullet)").each do |bullet|
            description << bullet.text.strip
          end

          # Join into newline-separated string
          description = description.join("\n\n").to_s

          # Monetize link
          referral_url = referralize($browser.current_url, AFFILIATE_ID)

          if Spree::Product.find_by_name(name)
            puts "Product exists, skipping..."
            next
          else
            begin
              created_product = Spree::Product.create!(
                name:,
                price:,
                description:,
                available_on: Time.current,
                shipping_category:,
                tax_category:,
                taxon_ids:,
                affiliate: true,
                referral_url:
              )
              puts created_product.name
            rescue ActiveRecord::RecordInvalid
              next
            end

            created_product.variants.create(
              option_values: values,
              sku: rand(100_000)
            )

            created_product.variants.each do |variant|
              thumbnails = $browser.at_css("#altImages")
              thumbnails.css("li.imageThumbnail").each do |thumbnail|
                # Click each thumbnails in order for their photos to appear in DOM
                thumbnail.at_css("input.a-button-input").click
              end

              images = $browser.at_css("#main-image-container")
              images.css("li.image").each do |image|
                # Get hi-res photos
                image_url = image.at_css("img").attribute("data-old-hires")

                if image_url.present?
                  downloaded_image = URI.open(image_url, "User-Agent" => $useragent)

                  # Do not include messy images with text
                  # text = Tesseract::Engine.new(downloaded_image).text

                  # if text.empty?
                  File.open(downloaded_image) do |file|
                    variant.images.create!(attachment: file)
                  end
                  puts "Saved #{ image_url }"
                  # else
                  #   puts "#{ image_url } has text, skipping..."
                  #   next
                  # end
                else
                  puts "No image, skipping..."
                  next
                end
              end
            end
          end
        end
      end

      def humanize
        delay = rand(2..8)
        puts "Sleeping #{ delay } seconds..."
        sleep delay

        $browser.mouse.move(x: rand(0..1024), y: rand(0..768))
      rescue Ferrum::TimeoutError
        puts "Timeout error, rescuing..."
      end

      def scroll_to_bottom
        loop do
          height = $browser.evaluate("document.documentElement.offsetHeight")

          puts "Scrolling to the bottom of the page (#{ height }px)..."

          $browser.mouse.scroll_to(0, height)
          new_height = $browser.evaluate("document.documentElement.offsetHeight")

          if height == new_height
            puts "Bottom reached"
            break
          end
        end
      end

      # https://github.com/henrik/delishlist.com/blob/master/lib/amazon_referralizer.rb

      def referralize(url, tag)
        asin = /[A-Z0-9]{10}/
        referral_id = /\w+-\d\d/

        url = url.to_s

        if %r{^https?://(.+\.)?(amazon\.|amzn\.com\b)}i.match?(url)
          url.sub!(%r{\b(#{ asin })\b(/#{ referral_id }\b)?}, "\\1")
          url.gsub!(/&tag=#{ referral_id }\b/, "")
          url.gsub!(/\?tag=#{ referral_id }\b/, "?")
          url.sub!(/\?$/, "")
          url.sub!(/\?&/, "?")

          separator = url.include?("?") ? "&" : "?"

          [url, "tag=#{ tag }"].join(separator)
        else
          url
        end
      end
    end

    # Popular user-agents
    # http://browser-info.net/useragents
    USERAGENTS = [
      "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.85 Safari/537.36",
      "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36",
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:34.0) Gecko/20100101 Firefox/34.0",
      "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:34.0) Gecko/20100101 Firefox/34.0",
      "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36",
      "Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/5.0)",
      "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53 (compatible; bingbot/2.0; http://www.bing.com/bingbot.htm)",
      "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; Media Center PC",
      "Mozilla/5.0 (Windows NT 6.2; WOW64; rv:34.0) Gecko/20100101 Firefox/34.0",
      "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/13.0.782.112 Safari/535.1",
      "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:30.0) Gecko/20100101 Firefox/30.0",
      "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko",
      "Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko",
      "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36",
      "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:41.0) Gecko/20100101 Firefox/41.0",
      "Mozilla/5.0 (iPad; U; CPU OS 5_1 like Mac OS X) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B367 Safari/531.21.10 UCBrowser/3.4.3.532",
      "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; FSL 7.0.6.01001)",
      "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; FSL 7.0.7.01001)",
      "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; FSL 7.0.5.01003)",
      "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0",
      "Mozilla/5.0 (Windows NT 5.1; rv:13.0) Gecko/20100101 Firefox/13.0.1",
      "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:11.0) Gecko/20100101 Firefox/11.0",
      "Mozilla/5.0 (Windows NT 5.1; rv:13.0) Gecko/20100101 Firefox/13.0.1",
      "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:13.0) Gecko/20100101 Firefox/13.0.1",
      "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)",
      "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)",
      "Opera/9.80 (Windows NT 5.1; U; en) Presto/2.10.289 Version/12.01",
      "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)",
      "Mozilla/5.0 (Windows NT 5.1; rv:5.0.1) Gecko/20100101 Firefox/5.0.1",
      "Mozilla/5.0 (Windows NT 6.1; rv:5.0) Gecko/20100101 Firefox/5.02",
      "Mozilla/5.0 (Windows NT 6.0) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/13.0.782.112 Safari/535.1"
    ]

    # --

    scrape = Scraper.new

    INFLUENCERS.each do |seller_page|
      scrape.get_seller_lists(seller_page[:url])
    end
  end
end
```

## `brgen/marketplace/brgen_marketplace.sh`
```
#!/usr/bin/env zsh

app_name="brgen_marketplace"
source __shared.sh

# ---

initialize_app_directory() {
  initialize_setup "$app_name"
  log "Initialized $app_name directory"
}

# ---

setup_frontend_with_rails() {
  log "Setting up front-end for $app_name"

  create_rails_app "$app_name"
  if ! bin/rails db:migrate; then
    error_exit "DB migration failed for $app_name"
  fi
  log "Rails setup completed for $app_name"

  generate_view_and_scss "brgen_marketplace/products/index" "<h1>Marketplace Products</h1><button>Add New Product</button>" "h1 { font-size: 2rem; } button { background-color: #4caf50; color: white; padding: 10px; border-radius: 5px; }"
  generate_view_and_scss "brgen_marketplace/products/show" "<h1>Product Details</h1><button>Buy Now</button>" "h1 { font-size: 2rem; } button { background-color: #4caf50; color: white; padding: 10px; border-radius: 5px; }"
  log "Frontend views setup for $app_name"

  yarn_install "swiper@8.0.7" "@stimulus-components/carousel@1.2.0" "@hotwired/turbo-rails@7.2.0"
  log "JavaScript components setup completed"
}

# ---

setup_app_specific() {
  log "Setting up specifics for $app_name"

  generate_model_with_validations "BrgenMarketplace::Product" "name:string price:decimal description:text user_id:integer" "validates :name, presence: true
validates :price, numericality: { greater_than: 0 }" "belongs_to :user"
  generate_model_with_validations "BrgenMarketplace::Order" "product_id:integer buyer_id:integer status:string" "validates :status, presence: true" "belongs_to :product"
  log "Models generated for $app_name"

  generate_controller_with_crud "BrgenMarketplace::Products" "BrgenMarketplace::Product" "name price description user_id"
  generate_controller_with_crud "BrgenMarketplace::Orders" "BrgenMarketplace::Order" "product_id buyer_id status"
  log "Controllers generated for $app_name"

  setup_redis || error_exit "Redis setup failed"
  if ! redis-cli ping | grep -q PONG; then
    error_exit "Redis health check failed"
  fi
  log "Redis setup completed"

  integrate_live_chat || error_exit "Live chat integration failed"
  configure_live_chat_backend || error_exit "Live chat backend configuration failed"
  log "Live chat setup completed"

  apply_common_features "$app_name"
  log "$app_name specifics setup completed"
}

# ---

seed_database() {
  log "Seeding database for $app_name"
  bin/rails db:seed || error_exit "Database seeding failed for $app_name"
  log "Database seeding completed for $app_name"
}

# ---

main() {
  log "Starting $app_name setup"
  initialize_app_directory
  setup_frontend_with_rails
  setup_app_specific
  seed_database
  log "$app_name setup finished"
}

main "$@"

```

## `brgen/marketplace/brgen_marketplace_README.md`
```
# Brgen Marketplace: Din Markedsplass på Nett 🛒🛍️

Brgen Marketplace er en nettbasert markedsplass som kombinerer funksjonene fra et tradisjonelt kjøp- og salg-forum med avanserte e-handelsmuligheter. Denne plattformen gir brukerne muligheten til å kjøpe og selge alt fra elektronikk til klær, og gir en opplevelse som minner om Amazon, men med fokus på lokal tilhørighet og brukerstyrte annonser.

## Funksjoner 🚀

- **Brukeropprettede Annonser** 📋: Lag, rediger og publiser dine egne annonser. Selg klær, elektronikk, møbler eller andre eiendeler du ikke trenger lenger.
- **Avansert Produktsøk** 🔍: Søk i hele markedsplassen etter spesifikke produkter, kategorier, eller bruk søkefiltre for å finne det du ser etter.
- **Personlige Salgsprofiler** 👤: Opprett en egen salgsprofil hvor du kan liste produktene dine og bygge et rykte som en pålitelig selger.
- **Chat-funksjon for Kjøpere og Selgere** 💬: Kommuniser direkte med potensielle kjøpere eller selgere for raskt å svare på spørsmål eller forhandle priser.
- **Geo-lokalisering** 📍: Se annonser i nærheten av deg, eller finn produkter som er tilgjengelige i ditt område.
- **AI Anbefalinger** 🤖✨: Få anbefalte produkter basert på din søkehistorikk og interesser ved hjelp av avanserte algoritmer.
- **PWA (Progressiv Web App)** 📱: Marketplace er tilgjengelig som en PWA, slik at brukerne kan få en mobilvennlig opplevelse og til og med bruke appen offline.
- **Mørk Modus som Standard** 🌙: Marketplace har mørk modus som gir en komfortabel visuell opplevelse, spesielt om natten.

## Teknologi 🚀

- **Ruby on Rails** 💎🚄: Den underliggende plattformen som håndterer alle funksjoner i markedsplassen.
- **PostgreSQL** 🐘: Databasen hvor alle produktannonser, brukerdata og meldinger lagres.
- **Hotwire (Turbo + Stimulus)** ⚡️: Brukes for å skape en sømløs og responsiv brukeropplevelse uten behov for tung JavaScript.
- **Stimulus Components** 🎛️: Brukes for interaktive elementer som produktkaruseller og skjemaer.
- **Swiper.js & LightGallery.js** 🎠🖼️: Integrert for produktkaruseller og for å kunne vise bilder i elegant lysbildefremvisning.
- **Internasjonalisering (i18n)** 🌍: Full språkstøtte som gjør at markedsplassen kan brukes av folk fra ulike land og kulturer.
- **AI Chat og Live Chat** 🗨️: Integrert for å tilby både AI-assisterte anbefalinger og sanntidskommunikasjon mellom kjøpere og selgere.

## Målsetting 🎯
Brgen Marketplace ønsker å gjøre kjøp og salg enklere, tryggere og mer lokaltilpasset, samtidig som brukerne får en moderne og responsiv netthandelsopplevelse. Plattformen gir folk mulighet til å være både kjøper og selger, og legger til rette for trygg kommunikasjon og praktiske e-handelsverktøy

```

## `brgen/marketplace/marketplace.sh`
```
#!/usr/bin/env zsh
set -e # Halt script execution on first error

echo "Starting comprehensive development of the BRGEN Marketplace with enhanced views..."

# Navigate to the main directory of your BRGEN Rails application
cd /path/to/brgen

# Setup environment and install necessary gems
echo "Adding and installing required gems..."
bundle add solidus --github='solidusio/solidus'
bundle add solidus_auth_devise --github='solidusio/solidus_auth_devise'
bundle add solidus_searchkick --github='solidusio-contrib/solidus_searchkick'
bundle add solidus_reviews --github='solidusio-contrib/solidus_reviews'

echo "Generating and migrating necessary installations..."
bin/rails generate solidus:install --auto-accept
bin/rails generate solidus_multi_vendor:install
bin/rails generate solidus_searchkick:install
bin/rails generate solidus_reviews:install
bin/rails db:migrate

git add .
git commit -m "Installed and configured Solidus and additional extensions for enhanced e-commerce functionalities."

# Implementing and updating views with clean, semantic HTML and internationalization support
echo "Updating views with enhanced, semantic HTML and internationalization support..."
cat <<ERB > app/views/marketplace/shared/_header.html.erb
<%= tag.header class: "main_header" do %>
  <%= link_to t("navigation.home"), root_path, class: "logo" %>
  <%= render 'marketplace/shared/navigation' %>
<% end %>
ERB

cat <<ERB > app/views/marketplace/shared/_navigation.html.erb
<%= tag.nav do %>
  <%= link_to t("navigation.products"), marketplace_products_path %>
  <%= link_to t("navigation.contact"), marketplace_contact_path %>
<% end %>
ERB

cat <<ERB > app/views/marketplace/home/index.html.erb
<%= render 'marketplace/shared/header' %>
<%= tag.div class: "main_content" do %>
  <%= render 'marketplace/shared/featured_products', locals: { featured_products: @featured_products } %>
  <%= render 'marketplace/shared/categories', locals: { categories: @categories } %>
<% end %>
<%= render 'marketplace/shared/footer' %>
ERB

cat <<ERB > app/views/marketplace/products/_product_card.html.erb
<%= tag.article class: "product_card", itemprop: "itemListElement", itemscope: true, itemtype: "http://schema.org/Product" do %>
  <%= link_to marketplace_product_path(product), itemprop: "url", class: "product_link" do %>
    <%= image_tag product.display_image, itemprop: "image", class: "product_image", alt: product.name %>
    <%= tag.div class: "product_details" do %>
      <%= tag.h2 product.name, itemprop: "name", class: "product_name" %>
      <%= tag.p product.description, itemprop: "description", class: "product_description" %>
      <%= tag.span number_to_currency(product.price), itemprop: "price", class: "product_price" %>
    <% end %>
  <% end %>
<% end %>
ERB

git add .
git commit -m "Updated views with clean, semantic HTML and I18n."
```

## `brgen/playlist/README.md`
```
# Enhanced Warp Tunnel Visualizer

## Overview
This project creates an immersive and interactive warp tunnel visualizer using a combination of p5.js and Three.js. It leverages audio analysis to create dynamic visual effects synchronized with music, achieving a stunning tunnel effect.

## Features
1. **3D Tunnel Visualization**: Utilizes Three.js to create a tunnel effect with rings and particles.
2. **Audio Synchronization**: Analyzes audio input to modulate the tunnel visualization.
3. **Realistic Motion**: Applies physics for realistic particle behavior.
4. **Color Gradients and Effects**: Uses dynamic colors and gradients to enhance visual appeal.
5. **Interactivity**: Enhanced mouse and touch interactions, including a parallax effect on mobile devices.
6. **Performance Optimization**: Ensures smooth and responsive rendering.
7. **User Controls**: Provides sliders and color pickers to adjust tunnel speed and colors.

## Implementation Details

### Setup
- **Three.js**: Handles the 3D rendering and scene management.
- **p5.js**: Manages audio input and FFT analysis.
- **Cannon.js**: Adds realistic physics to particle movement.
- **Dynamic Color Gradients**: Applied through shaders in Three.js, modulated by audio data.
- **Interactivity**: Mouse and touch event listeners for enhanced user interaction.

### Visual Effects
- **Physics for Realism**: Integrate Cannon.js for realistic particle movement and interactions.
- **Color Gradients**: Apply dynamic color gradients based on audio data.
- **Stark Contrast Colors**: Retain the original stark contrast color scheme.
- **Interactivity**: Enhanced mouse and touch interactions, adding a parallax effect for mobile.
- **Performance Optimization**: Efficient rendering techniques ensure smooth and responsive animations.

## Usage
1. Open the `index.html` file in a modern browser.
2. Click the "Play Audio" button to start the visualizer.
3. Use the mouse to interact with the visualizer. On mobile devices, move your device to see the parallax effect.
4. Adjust the tunnel speed and color using the provided controls.

## Known Issues
- Ensure the browser allows audio context to start after user interaction to avoid restrictions.
- Performance may vary based on the device's capabilities.

## Future Enhancements
- Further optimize rendering for even smoother animations.
- Add more complex visual effects and interactivity options.
- Explore additional audio sources and visualization techniques.

## Development Process

### Identify Bugs and Issues
- Look for syntax errors, potential issues, deprecated methods, and logical inconsistencies.
- Use browser console and debugging tools to track down and fix errors.

### Code Refactoring
- DRY (Don't Repeat Yourself) up the code to reduce redundancy.
```

## `brgen/playlist/brgen_playlist.sh`
```
#!/usr/bin/env zsh

app_name="brgen_playlist"
source __shared.sh

# ---

initialize_app_directory() {
  initialize_setup "$app_name"
  log "Initialized $app_name directory"
}

# ---

setup_frontend_with_rails() {
  log "Setting up front-end for $app_name"

  create_rails_app "$app_name"
  if ! bin/rails db:migrate; then
    error_exit "DB migration failed for $app_name"
  fi
  log "Rails setup completed for $app_name"

  generate_view_and_scss "brgen_playlist/playlists/index" "<h1>Your Playlists</h1><button>Create New Playlist</button>" "h1 { font-size: 2rem; } button { background-color: #00bcd4; color: white; padding: 10px; border-radius: 5px; }"
  generate_view_and_scss "brgen_playlist/songs/index" "<h1>Songs in Playlist</h1><button>Add Song</button>" "h1 { font-size: 2rem; } button { background-color: #00bcd4; color: white; padding: 10px; border-radius: 5px; }"
  log "Frontend views setup for $app_name"

  yarn_install "swiper@8.0.7" "@stimulus-components/carousel@1.2.0" "@hotwired/turbo-rails@7.2.0"
  log "JavaScript components setup completed"
}

# ---

setup_app_specific() {
  log "Setting up specifics for $app_name"

  generate_model_with_validations "BrgenPlaylist::Playlist" "name:string description:text user_id:integer" "validates :name, presence: true" "belongs_to :user"
  generate_model_with_validations "BrgenPlaylist::Song" "title:string artist:string album:string duration:integer playlist_id:integer" "validates :title, presence: true" "belongs_to :playlist"
  log "Models generated for $app_name"

  generate_controller_with_crud "BrgenPlaylist::Playlists" "BrgenPlaylist::Playlist" "name description user_id"
  generate_controller_with_crud "BrgenPlaylist::Songs" "BrgenPlaylist::Song" "title artist album duration playlist_id"
  log "Controllers generated for $app_name"

  setup_redis || error_exit "Redis setup failed"
  if ! redis-cli ping | grep -q PONG; then
    error_exit "Redis health check failed"
  fi
  log "Redis setup completed"

  integrate_live_chat || error_exit "Live chat integration failed"
  configure_live_chat_backend || error_exit "Live chat backend configuration failed"
  log "Live chat setup completed"

  apply_common_features "$app_name"
  log "$app_name specifics setup completed"
}

# ---

seed_database() {
  log "Seeding database for $app_name"
  bin/rails db:seed || error_exit "Database seeding failed for $app_name"
  log "Database seeding completed for $app_name"
}

# ---

main() {
  log "Starting $app_name setup"
  initialize_app_directory
  setup_frontend_with_rails
  setup_app_specific
  seed_database
  log "$app_name setup finished"
}

main "$@"

```

## `brgen/playlist/brgen_playlist_README.md`
```
# Brgen Playlist Service

**Brgen Playlist** is a hyper-localized audio-sharing platform inspired by the concept of **Whyp.it**. It enables users to discover, share, and collaborate on audio recordings, podcasts, and music with people in their community. Unlike traditional music platforms, Brgen Playlist focuses on simplicity and community-driven content, encouraging users to record and share their thoughts, music, and stories directly.

### Key Features

- **Community Audio Sharing**: Share music, podcasts, and voice recordings with others in your city.
- **Simplicity and Accessibility**: A straightforward interface that makes uploading and sharing audio easy for everyone.
- **Local Discovery**: Discover what people around you are talking about, recording, and creating.
- **High-Quality Audio**: Stream audio at high-quality bitrates, ensuring a great listening experience for the community.
- **Embeddable Players**: Easily embed your audio content into blogs and websites using custom audio players.
- **Analytics and Insights**: Track audio performance with built-in analytics to understand audience engagement.
- **Privacy Settings**: Control who can view, comment on, and download your audio content.
- **Expiration Dates**: Set expiration dates for audio tracks, allowing for temporary content sharing.
- **Local Artist and Creator Support**: Connect with and support musicians, podcasters, and creators in your community.

### Target Audience

- **Local Creators**: Podcasters, musicians, and anyone interested in sharing audio content.
- **Community Members**: Users who enjoy discovering local content, stories, and opinions.
- **Simple Sharing Advocates**: People who prefer an easy, no-fuss way to record and share audio.
- **Content Creators**: Artists who want detailed analytics and the ability to embed content elsewhere.

### Monetization Strategies

- **Ad-supported Free Tier**: Local audio content supported by non-intrusive ads.
- **Premium Subscription**: Access advanced features such as longer recording times, higher quality uploads, analytics, and ad-free experiences.
- **Creator Donations**: Enable users to support their favorite creators through small donations.
- **Sponsored Content**: Partner with local brands for sponsored playlists and promotions.

### Summary

Brgen Playlist is inspired by **Whyp.it** and aims to provide a hyper-localized audio-sharing experience that is simple and accessible. By focusing on community-driven content, high-quality audio streaming, and supporting grassroots creators, Brgen Playlist encourages authentic storytelling and the sharing of ideas within communities.

---

This README has been updated to incorporate additional inspiration from **Whyp.it**, emphasizing features such as high-quality streaming, embeddable players, analytics, and flexible privacy settings. Let me know if there are further refinements you'd like to explore.

```

## `brgen/playlist/demo.html`
```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Warp Tunnel Visualizer</title>
    <style>
        body { margin: 0; overflow: hidden; background: black; }
        #audio-controls { position: absolute; top: 10px; left: 10px; color: white; }
    </style>
</head>
<body>
    <div id="audio-controls">
        <button id="btStartAudioVisualization">Start Audio Visualization</button>
        <div id="txtStatus">Waiting Patiently For You... Please Click the Start Button.</div>
    </div>
    <script>
        var audio, audioContext, audioSrc;
        var analyser, analyserBufferLength;

        var w, h;
        var btStart, txtStatus, canvas, context;

        var imageData, data;

        var mouseActive = false, mouseDown = false;
        var mousePos = { x: 0, y: 0 };
        var mouseFollowSpeed = 0.015;

        var fov = 250, speed = 0.75;
        var particles = [], particlesCenter = [];
        var time = 0, colorInvertValue = 0;

        function init() {
            canvas = document.createElement('canvas');
            canvas.addEventListener('mousedown', mouseDownHandler, false);
            canvas.addEventListener('mouseup', mouseUpHandler, false);
            canvas.addEventListener('mousemove', mouseMoveHandler, false);
            canvas.addEventListener('mouseenter', mouseEnterHandler, false); 
            canvas.addEventListener('mouseleave', mouseLeaveHandler, false); 

            document.body.appendChild(canvas);
            context = canvas.getContext('2d');

            window.addEventListener('resize', onResize, false);
            onResize();
            addParticles();
            render();
            clearImageData();
            render();
            context.putImageData(imageData, 0, 0);

            btStart = document.getElementById('btStartAudioVisualization');
            btStart.addEventListener('mousedown', userStart, false);

            txtStatus = document.getElementById('txtStatus');
            txtStatus.innerHTML = 'Waiting Patiently For You... Please Click the Start Button.';
        }

        function userStart() {
            btStart.removeEventListener('mousedown', userStart);
            btStart.addEventListener('mousedown', audioBtHandler, false);
            btStart.innerHTML = 'Pause Audio';

            txtStatus.innerHTML = 'Loading Audio...';
            audioSetup();
            animate();
        }

        function audioSetup() {
            audio = new Audio();
            audio.src = 'http://nkunited.de/ExternalImages/jsfiddle/audio/ChillDay_comp.mp3';
            audio.controls = false;
            audio.loop = true;
            audio.autoplay = true;
            audio.crossOrigin = 'anonymous';
            audio.addEventListener('canplaythrough', audioLoaded, false);

            audioContext = new (window.AudioContext || window.webkitAudioContext)();
            analyser = audioContext.createAnalyser();
            analyser.connect(audioContext.destination);
            analyser.smoothingTimeConstant = 0.65;
            analyser.fftSize = 512 * 32;
            analyserBufferLength = analyser.frequencyBinCount;

            audioSrc = audioContext.createMediaElementSource(audio); 
            audioSrc.connect(analyser);
        }

        function audioLoaded(event) {
            txtStatus.innerHTML = 'Song: LAKEY INSPIRED - Chill Day';
        }

        function clearImageData() {
            for (var i = 0, l = data.length; i < l; i += 4) {
                data[i] = 0;
                data[i + 1] = 0;
                data[i + 2] = 0;
                data[i + 3] = 255;
            }
        }

        function setPixel(x, y, r, g, b, a) {
            var i = (x + y * imageData.width) * 4;
            data[i] = r;
            data[i + 1] = g;
            data[i + 2] = b;
            data[i + 3] = a;
        }

        function drawLine(x1, y1, x2, y2, r, g, b, a) {
            var dx = Math.abs(x2 - x1);
            var dy = Math.abs(y2 - y1);
            var sx = (x1 < x2) ? 1 : -1;
            var sy = (y1 < y2) ? 1 : -1;
            var err = dx - dy;

            var lx = x1, ly = y1;    
            while (true) {
                if (lx > 0 && lx < w && ly > 0 && ly < h) {
                    setPixel(lx, ly, r, g, b, a);
                }
                if (lx === x2 && ly === y2) break;
                var e2 = 2 * err;
                if (e2 > -dx) { err -= dy; lx += sx; }
                if (e2 < dy) { err += dx; ly += sy; }
            }
        }

        function getCirclePosition(centerX, centerY, radius, index, segments) {
            var angle = index * ( (Math.PI * 2) / segments ) + time;
            var x = centerX + Math.cos(angle) * radius;
            var y = centerY + Math.sin(angle) * radius;
            return { x: x, y: y };
        }

        function drawCircle(centerPosition, radius, segments) {
            var coordinates = [];
            var radiusSave;
            var diff = 0;

            for (var i = 0; i <= segments; i++) {
                var radiusRandom = radius;
                if (i === 0) radiusSave = radiusRandom;
                if (i === segments) radiusRandom = radiusSave;
                var centerX = centerPosition.x;
                var centerY = centerPosition.y;
                var position = getCirclePosition(centerX, centerY, radiusRandom, i, segments);
                coordinates.push({ x: position.x, y: position.y, index: i + diff, radius: radiusRandom, segments: segments, centerX: centerX, centerY: centerY });
            }
            return coordinates;
        }

        function addParticle(x, y, z, audioBufferIndex) {
            var particle = { x: x, y: y, z: z, x2d: 0, y2d: 0, audioBufferIndex: audioBufferIndex };
            return particle;
        }

        function addParticles() {
            var audioBufferIndexMin = 8;
            var audioBufferIndexMax = 1024;
            var audioBufferIndex = audioBufferIndexMin;

            var centerPosition = { x: 0, y: 0 };
            var center = { x: 0, y: 0 };
            var c = 0;
            var w1 = Math.random() * (w / 1);
            var h1 = Math.random() * (h / 1);

            for (var z = -fov; z < fov; z += 4) {
                var coordinates = drawCircle(centerPosition, 75, 64);
                var particlesRow = [];
                center.x = ((w / 2) - w1) * (c / 15) + w / 2;
                center.y = ((h / 2) - h1) * (c / 15) + w / 2;
                c++;
                particlesCenter.push(center);
                audioBufferIndex = Math.floor(Math.random() * audioBufferIndexMax) + audioBufferIndexMin;

                for (var i = 0, l = coordinates.length; i < l; i++) {
                    var coordinate = coordinates[i];
                    var particle = addParticle(coordinate.x, coordinate.y, z, audioBufferIndex);
                    particle.index = coordinate.index;
                    particle.radius = coordinate.radius;
                    particle.radiusAudio = particle.radius;
                    particle.segments = coordinate.segments;
                    particle.centerX = coordinate.centerX;
                    particle.centerY = coordinate.centerY;
                    particlesRow.push(particle);
                    if (i < coordinates.length / 2) audioBufferIndex++;
                    else audioBufferIndex--;
                    if (audioBufferIndex > audioBufferIndexMax) audioBufferIndex = audioBufferIndexMin;
                    if (audioBufferIndex < audioBufferIndexMin) audioBufferIndex = audioBufferIndexMax;
                }
                particles.push(particlesRow);
            }
        }

        function onResize() {
            w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
            h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
            canvas.width = w;
            canvas.height = h;
            context.fillStyle = '#000000';
            context.fillRect(0, 0, w, h);
            imageData = context.getImageData(0, 0, w, h);
            data = imageData.data;
        }

        function audioBtHandler(event) {
            if (audio.paused) {
                audio.play();
                btStart.innerHTML = 'Pause Audio';
            } else {
                audio.pause();
                btStart.innerHTML = 'Play Audio';
            }
        }

        function mouseDownHandler(event) {
            mouseDown = true;
        }

        function mouseUpHandler(event) {
            mouseDown = false;
        }

        function mouseEnterHandler(event) {
            mouseActive = true;
        }

        function mouseLeaveHandler(event) {
            mouseActive = false;
            mousePos.x = w / 2;
            mousePos.y = h / 2;
            mouseDown = false;
        }

        function mouseMoveHandler(event) {
            mousePos = getMousePos(canvas, event);
        }

        function getMousePos(canvas, event) {
            var rect = canvas.getBoundingClientRect();
            return { x: event.clientX - rect.left, y: event.clientY - rect.top };
        }

        function render() {
            var frequencySource;
            if (analyser) {
                frequencySource = new Uint8Array(analyser.frequencyBinCount);
                analyser.getByteFrequencyData(frequencySource);
            }

            var sortArray = false;
            for (var i = 0, l = particles.length; i < l; i++) {
                var particlesRow = particles[i];
                var particlesRowBack;
                if (i > 0) {
                    particlesRowBack = particles[i - 1];
                }

                var center = particlesCenter[i];
                if (mouseActive) {
                    center.x = ((w / 2) - mousePos.x) * ((particlesRow[0].z - fov) / 500) + w / 2;
                    center.y = ((h / 2) - mousePos.y) * ((particlesRow[0].z - fov) / 500) + h / 2;
                } else {
                    center.x += ((w / 2) - center.x) * mouseFollowSpeed;
                    center.y += ((h / 2) - center.y) * mouseFollowSpeed;
                }

                for (var j = 0, k = particlesRow.length; j < k; j++) {
                    var particle = particlesRow[j];
                    var scale = fov / (fov + particle.z);
                    particle.x2d = (particle.x * scale) + center.x;
                    particle.y2d = (particle.y * scale) + center.y;

                    if (analyser) {
                        var frequency = frequencySource[particle.audioBufferIndex];
                        var frequencyAdd = frequency / 8;
                        particle.radiusAudio = particle.radius + frequencyAdd;
                    } else {
                        particle.radiusAudio = particle.radius;
                    }

                    if (mouseDown) {
                        particle.z += speed;
                        if (particle.z > fov) {
                            particle.z -= (fov * 2);
                            sortArray = true;
                        }
                    } else {
                        particle.z -= speed;
                        if (particle.z < -fov) {
                            particle.z += (fov * 2);
                            sortArray = true;
                        }
                    }

                    var lineColorValue = 0;
                    if (j > 0) {
                        var p = particlesRow[j - 1];
                        lineColorValue = Math.round(i / l * 200);
                        drawLine(particle.x2d | 0, particle.y2d | 0, p.x2d | 0, p.y2d | 0, 0, Math.round(lineColorValue / 2), lineColorValue, 255);
                    }

                    var position;
                    if (j < k - 1) {
                        position = getCirclePosition(particle.centerX, particle.centerY, particle.radiusAudio, particle.index, particle.segments);
                    } else {
                        var p1 = particlesRow[0];
                        position = getCirclePosition(p1.centerX, p1.centerY, p1.radiusAudio, p1.index, p1.segments);
                    }
                    particle.x = position.x;
                    particle.y = position.y;

                    if (i > 0 && i < l - 1) {
                        var pB;
                        if (j === 0) {
                            pB = particlesRowBack[particlesRowBack.length - 1];
                        } else {
                            pB = particlesRowBack[j - 1];
                        }
                        drawLine(particle.x2d | 0, particle.y2d | 0, pB.x2d | 0, pB.y2d | 0, 0, Math.round(lineColorValue / 2), lineColorValue, 255);
                    }
                }
            }

            if (sortArray) {
                particles = particles.sort(function(a, b) {
                    return (b[0].z - a[0].z);
                });
            }

            if (mouseDown) {
                time -= 0.005;
            } else {
                time += 0.005;
            }

            if (mouseDown) {
                if (colorInvertValue < 255)
                    colorInvertValue += 5;
                else
                    colorInvertValue = 255;
                softInvert(colorInvertValue);
            } else {
                if (colorInvertValue > 0)
                    colorInvertValue -= 5;
                else
                    colorInvertValue = 0;
                if (colorInvertValue > 0)
                    softInvert(colorInvertValue);
            }
        }

        function softInvert(value) {
            for (var j = 0, n = data.length; j < n; j += 4) {
                data[j] = Math.abs(value - data[j]);
                data[j + 1] = Math.abs(value - data[j + 1]);
                data[j + 2] = Math.abs(value - data[j + 2]);
                data[j + 3] = 255;
            }
        }

        function animate() {
            clearImageData();
            render();
            context.putImageData(imageData, 0, 0);
            requestAnimationFrame(animate);
        }

        window.requestAnimFrame = (function() {
            return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || function(callback) {
                window.setTimeout(callback, 1000 / 60);
            };
        })();

        init();
    </script>
</body>
</html>
```

## `brgen/playlist/playlist.html`
```
<html>
  <head>
    <meta charset="utf-8">
    <title>Playlist Los Angeles - playlist.lsangeles.com</title>
    <link rel="stylesheet" href="https://unpkg.com/swiper/swiper-bundle.min.css">
    <script src="https://unpkg.com/swiper/swiper-bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/css-doodle/0.6.1/css-doodle.min.js"></script>
    <script async charset="utf-8" src="https://cdn.iframe.ly/embed.js?api_key=78d408e0b569d36bb547fe"></script>
    <style>
      css-doodle {
        --color: @p(#51eaea, #fffde1, #ff9d76, #FB3569);
        --filter: @svg-filter(
          <svg>
            <filter>
              <feTurbulence type="fractalNoise"
                baseFrequency=".08"
                numOctaves="2"
                seed="200"
              />
              <feDisplacementMap in="SourceGraphic" scale="100" />
            </filter>
          </svg>
        );

        --rule: (
          :doodle {
            @grid: 30x1 / 18vmin;
          }

          :container {
            perspective: 30vmin;
          }

          @place-cell: center;
          @size: 100%;

          :after, :before {
            content: "";
            @size: 100%;
            position: absolute;
            border: 2.4vmin solid var(--color);
            border-image: radial-gradient(var(--color), transparent 60%);
            border-image-width: 4;
            transform: rotate(@pn(0, 5deg));
          }

          will-change: transform, opacity;
          animation: scale-up 15s linear infinite;
          animation-delay: calc(-15s / @size() * @i());
          box-shadow: inset 0 0 1em var(--color);
          border-radius: 50%;
          filter: var(--filter);

          @keyframes scale-up {
            0%, 100% {
              transform: translateZ(0) scale(0) rotate(0);
              opacity: 0;
            }
            50% {
              opacity: 1;
            }
            99% {
              transform: translateZ(30vmin) scale(1) rotate(-270deg);
            }
          }
        )
      }

      * {
        color: white;
      }

      html, body {
        position: relative;
        height: 100%;
      }

      body {
        font-family: Helvetica Neue, Helvetica, Arial, sans-serif;
        font-size: 14px;
        background: black;
        color: white;
        text-transform: lowercase;
        margin: 0;
        padding: 0;
      }

      .swiper-container {
        height: 100%;
        width: 100%;
      }

      .swiper-slide {
        overflow: hidden;
        text-align: center;
        font-size: 18px;
        background: #fff;
        display: -webkit-box;
        display: -ms-flexbox;
        display: -webkit-flex;
        display: flex;
        -webkit-box-pack: center;
        -ms-flex-pack: center;
        -webkit-justify-content: center;
        justify-content: center;
        -webkit-box-align: center;
        -ms-flex-align: center;
        -webkit-align-items: center;
        align-items: center;
      }

      .iframely-embed {
        width: 100%;
        height: 100%;
        overflow: auto;
        padding-left: 8%;
        padding-right: 8%;
        background: black;
      }

      .iframely-responsive {
        top: 22% !important;
        left: -10% !important;
        width: 120% !important;
        height: 50% !important;
        position: relative;
        padding-bottom: 50%;
        box-sizing: border-box;
      }

      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }

      body {
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: clip;
      }

      .swiper-doodle {
        background: #270F34;
      }

      .intro {
        position: absolute;
        z-index: 1000;
        top: 65px;
        line-height: 38px;
      }

      .logo {
        position: absolute;
        z-index: 1000;
        bottom: 55px;
        line-height: 38px;
      }

      h1, h2, h3, h4 {
        letter-spacing: -0.2px;
      }

      h1 {
        font-size: 55px;
      }

      h2 {
        font-size: 33px;
      }

      h3 {
        position: absolute;
        color: white;
      }

      h3.artist {
        top: 20%;
        font-size: 84px;
      }

      h3.track {
        bottom: 20%;
        font-size: 66px;
      }

      h3.artist, h3.track, .vote {
        position: absolute;
        z-index: 1;
      }

      .vote {
        position: absolute;
        bottom: 4%;
        right: 6%;
        display: flex;
        flex-direction: column;
        align-items: center;
      }

      .upvote, .downvote {
        content: "";
        background-image: url(arrow_vote.svg);
        background-repeat: no-repeat;
        height: 114px;
        width: 120%;
        background-position: center;
        background-size: 52%;
      }

      .downvote {
        transform: rotate(180deg);
      }

      .score {
        font-size: 84px;
        margin: 16px 0;
      }
    </style>
  </head>
  <body>
    <div class="swiper-container swiper-container-h">
      <div class="swiper-wrapper">
        <div class="swiper-slide swiper-doodle">
          <div class="intro">
            <h1>Sveip for å begynne</h1>
          </div>
          <div class="logo">
            <h2>spilleliste.brgen.no</h2>
          </div>
          <css-doodle use="var(--rule)"></css-doodle>
        </div>
        <div class="swiper-slide">
          <h3 class="artist">Nahamasy & DJ Poolboi</h3>
          <a href="https://www.youtube.com/watch?v=32RHUW0LQKQ" data-iframely-url class="iframely-anchor">https://www.youtube.com/watch?v=32RHUW0LQKQ</a>
          <h3 class="track">Let Go</h3>
          <div class="vote">
            <a class="upvote"><!-- Upvote --></a>
            <span class="score">123</span>
            <a class="downvote"><!-- Downvote --></a>
          </div>
        </div>
        <div class="swiper-slide">
          <h3 class="artist">Madrugada</h3>
          <a href="https://www.youtube.com/watch?v=JcaynoMYGR8" data-iframely-url class="iframely-anchor">https://www.youtube.com/watch?v=JcaynoMYGR8</a>
          <h3 class="track">Call My Name</h3>
          <div class="vote">
            <a class="upvote"><!-- Upvote --></a>
            <span class="score">123</span>
            <a class="downvote"><!-- Downvote --></a>
          </div>
        </div>
        <div class="swiper-slide">
          <h3 class="artist">Röyksopp</h3>
          <a href="https://youtube.com/watch?v=QLnFpjHArwQ" data-iframely-url class="iframely-anchor">https://youtube.com/watch?v=QLnFpjHArwQ</a>
          <h3 class="track">In Space</h3>
          <div class="vote">
            <a class="upvote"><!-- Upvote --></a>
            <span class="score">123</span>
            <a class="downvote"><!-- Downvote --></a>
          </div>
        </div>
        <div class="swiper-slide">
          <h3 class="artist">Daniel Klauser</h3>
          <a href="https://youtube.com/watch?v=H6jNYY4GRr0" data-iframely-url class="iframely-anchor">https://youtube.com/watch?v=H6jNYY4GRr0</a>
          <h3 class="track">Always I'm Back Here</h3>
          <div class="vote">
            <a class="upvote"><!-- Upvote --></a>
            <span class="score">123</span>
            <a class="downvote"><!-- Downvote --></a>
          </div>
        </div>
        <div class="swiper-slide">
          <h3 class="artist">Röyksopp</h3>
          <a href="https://youtube.com/watch?v=8Gy_zq_YuQQ" data-iframely-url class="iframely-anchor">https://youtube.com/watch?v=8Gy_zq_YuQQ</a>
          <h3 class="track">Remind Me</h3>
          <div class="vote">
            <a class="upvote"><!-- Upvote --></a>
            <span class="score">123</span>
            <a class="downvote"><!-- Downvote --></a>
          </div>
        </div>
        <div class="swiper-slide">
          <h3 class="artist">Afta-1</h3>
          <a href="https://youtube.com/watch?v=fzBuXumxDX4" data-iframely-url class="iframely-anchor">https://youtube.com/watch?v=fzBuXumxDX4</a>
          <h3 class="track">4nia (92)</h3>
          <div class="vote">
            <a class="upvote"><!-- Upvote --></a>
            <span class="score">123</span>
            <a class="downvote"><!-- Downvote --></a>
          </div>
        </div>
        <div class="swiper-slide">
          <h3 class="artist">Guizz</h3>
          <a href="https://www.youtube.com/watch?v=9FfLoFaryxw" data-iframely-url class="iframely-anchor">https://www.youtube.com/watch?v=9FfLoFaryxw</a>
          <h3 class="track">Introspección</h3>
          <div class="vote">
            <a class="upvote"><!-- Upvote --></a>
            <span class="score">123</span>
            <a class="downvote"><!-- Downvote --></a>
          </div>
        </div>
        <div class="swiper-slide">
          <h3 class="artist">Afta-1</h3>
          <a href="https://youtube.com/watch?v=ADvXTRu9yJM" data-iframely-url class="iframely-anchor">https://youtube.com/watch?v=ADvXTRu9yJM</a>
          <h3 class="track">Yellow</h3>
          <div class="vote">
            <a class="upvote"><!-- Upvote --></a>
            <span class="score">123</span>
            <a class="downvote"><!-- Downvote --></a>
          </div>
        </div>
      </div>
    </div>
    <script>
      window.onload = function() {
        var swiperH = new Swiper(".swiper-container-h", {
          spaceBetween: 50,
          pagination: {
            el: ".swiper-pagination-h",
            clickable: true
          }
        });

        var swiperV = new Swiper(".swiper-container-v", {
          direction: "vertical",
          spaceBetween: 50,
          pagination: {
            el: ".swiper-pagination-v",
            clickable: true
          }
        });

        var linkElement = document.querySelector("a.iframely-anchor");
        iframely.load(linkElement);
      }
    </script>
  </body>
</html>

```

## `brgen/playlist/playlist.sh`
```
echo "Setting up Playlist subapp..."
# Generate models for Playlist subapp
bin/rails generate model Playlist::Set name:string description:text user:references
bin/rails generate model Playlist::Track name:string artist:string audio_url:string set:references
bin/rails db:migrate

# Creating Playlist controllers and views
mkdir -p app/controllers/playlist
cat <<RUBY > app/controllers/playlist/sets_controller.rb
module Playlist
  class SetsController < ApplicationController
    before_action :set_set, only: [:show, :edit, :update, :destroy]

    def index
      @sets = Set.includes(:tracks).all
    end

    def show
    end

    def new
      @set = Set.new
    end

    def create
      @set = Set.new(set_params)
      if @set.save
        redirect_to playlist_set_path(@set), notice: "Set was successfully created."
      else
        render :new
      end
    end

    def update
      if @set.update(set_params)
        redirect_to playlist_set_path(@set), notice: "Set was successfully updated."
      else
        render :edit
      end
    end

    def destroy
      @set.destroy
      redirect_to playlist_sets_path, notice: "Set was successfully destroyed."
    end

    private

    def set_set
      @set = Set.find(params[:id])
    end

    def set_params
      params.require(:set).permit(:name, :description, :user_id)
    end
  end
end
RUBY

mkdir -p app/views/playlist/sets
cat <<ERB > app/views/playlist/sets/index.html.erb
<%= tag.div do %>
  <% @sets.each do |set| %>
    <%= tag.div itemscope itemtype="http://schema.org/MusicPlaylist" do %>
      <%= link_to set.name, playlist_set_path(set), itemprop: "name" %>
      <%= tag.p set.description, itemprop: "description" %>
    <% end %>
  <% end %>
<% end %>
ERB

git add .
git commit -m "Setup Playlist subapp with models, controllers, and views including schema.org microdata"
```

## `brgen/takeaway/brgen_takeaway.sh`
```
#!/usr/bin/env zsh

app_name="brgen_takeaway"
source __shared.sh

# ---

initialize_app_directory() {
  initialize_setup "$app_name"
  log "Initialized $app_name directory"
}

# ---

setup_frontend_with_rails() {
  log "Setting up front-end for $app_name"

  create_rails_app "$app_name"
  if ! bin/rails db:migrate; then
    error_exit "DB migration failed for $app_name"
  fi
  log "Rails setup completed for $app_name"

  generate_view_and_scss "brgen_takeaway/restaurants/index" "<h1>Restaurants</h1><button>Order Food</button>" "h1 { font-size: 2rem; } button { background-color: #ff5722; color: white; padding: 10px; border-radius: 5px; }"
  generate_view_and_scss "brgen_takeaway/orders/index" "<h1>Your Orders</h1><button>Track Order</button>" "h1 { font-size: 2rem; } button { background-color: #ff5722; color: white; padding: 10px; border-radius: 5px; }"
  log "Frontend views setup for $app_name"

  yarn_install "swiper@8.0.7" "@stimulus-components/carousel@1.2.0" "@hotwired/turbo-rails@7.2.0"
  log "JavaScript components setup completed"
}

# ---

setup_app_specific() {
  log "Setting up specifics for $app_name"

  generate_model_with_validations "BrgenTakeaway::Restaurant" "name:string location:string cuisine:string user_id:integer" "validates :name, presence: true" "belongs_to :user"
  generate_model_with_validations "BrgenTakeaway::Order" "restaurant_id:integer user_id:integer status:string total_price:decimal" "validates :status, presence: true
validates :total_price, numericality: { greater_than: 0 }" "belongs_to :restaurant"
  log "Models generated for $app_name"

  generate_controller_with_crud "BrgenTakeaway::Restaurants" "BrgenTakeaway::Restaurant" "name location cuisine user_id"
  generate_controller_with_crud "BrgenTakeaway::Orders" "BrgenTakeaway::Order" "restaurant_id user_id status total_price"
  log "Controllers generated for $app_name"

  setup_redis || error_exit "Redis setup failed"
  if ! redis-cli ping | grep -q PONG; then
    error_exit "Redis health check failed"
  fi
  log "Redis setup completed"

  integrate_live_chat || error_exit "Live chat integration failed"
  configure_live_chat_backend || error_exit "Live chat backend configuration failed"
  log "Live chat setup completed"

  apply_common_features "$app_name"
  log "$app_name specifics setup completed"
}

# ---

seed_database() {
  log "Seeding database for $app_name"
  bin/rails db:seed || error_exit "Database seeding failed for $app_name"
  log "Database seeding completed for $app_name"
}

# ---

main() {
  log "Starting $app_name setup"
  initialize_app_directory
  setup_frontend_with_rails
  setup_app_specific
  seed_database
  log "$app_name setup finished"
}

main "$@"

```

## `brgen/takeaway/takeaway.sh`
```
echo "Setting up Takeaway subapp..."
# Generate models for Takeaway items and orders
bin/rails generate model Takeaway::Item name:string description:text price:decimal
bin/rails generate model Takeaway::Order user:references status:string
bin/rails db:migrate

# Creating Takeaway controllers and views
mkdir -p app/controllers/takeaway
cat <<RUBY > app/controllers/takeaway/items_controller.rb
module Takeaway
  class ItemsController < ApplicationController
    def index
      @items = Item.all
    end

    def show
      @item = Item.find(params[:id])
    end
  end
end
RUBY

mkdir -p app/views/takeaway/items
cat <<ERB > app/views/takeaway/items/index.html.erb
<%= tag.div do %>
  <% @items.each do |item| %>
    <%= tag.div itemscope itemtype="http://schema.org/Product" do %>
      <%= link_to item.name, takeaway_item_path(item), itemprop: "name" %>
      <%= tag.p item.description, itemprop: "description" %>
      <%= tag.span number_to_currency(item.price), class: "price", itemprop: "price" %>
    <% end %>
  <% end %>
<% end %>
ERB

git add .
git commit -m "Setup Takeaway subapp with models, controllers, and views including schema.org microdata"
```

## `brgen/tv/brgen_tv.sh`
```
#!/usr/bin/env zsh

app_name="brgen_tv"
source __shared.sh

# ---

initialize_app_directory() {
  initialize_setup "$app_name"
  log "Initialized $app_name directory"
}

# ---

setup_frontend_with_rails() {
  log "Setting up front-end for $app_name"

  create_rails_app "$app_name"
  if ! bin/rails db:migrate; then
    error_exit "DB migration failed for $app_name"
  fi
  log "Rails setup completed for $app_name"

  generate_view_and_scss "brgen_tv/shows/index" "<h1>TV Shows</h1><button>Explore Shows</button>" "h1 { font-size: 2rem; } button { background-color: #673ab7; color: white; padding: 10px; border-radius: 5px; }"
  generate_view_and_scss "brgen_tv/shows/show" "<h1>Show Details</h1><button>Watch Now</button>" "h1 { font-size: 2rem; } button { background-color: #673ab7; color: white; padding: 10px; border-radius: 5px; }"
  log "Frontend views setup for $app_name"

  yarn_install "swiper@8.0.7" "@stimulus-components/carousel@1.2.0" "@hotwired/turbo-rails@7.2.0"
  log "JavaScript components setup completed"
}

# ---

setup_app_specific() {
  log "Setting up specifics for $app_name"

  generate_model_with_validations "BrgenTv::Show" "title:string genre:string description:text release_date:date user_id:integer" "validates :title, presence: true" "belongs_to :user"
  generate_model_with_validations "BrgenTv::Episode" "title:string duration:integer show_id:integer release_date:date" "validates :title, presence: true" "belongs_to :show"
  log "Models generated for $app_name"

  generate_controller_with_crud "BrgenTv::Shows" "BrgenTv::Show" "title genre description release_date user_id"
  generate_controller_with_crud "BrgenTv::Episodes" "BrgenTv::Episode" "title duration show_id release_date"
  log "Controllers generated for $app_name"

  setup_redis || error_exit "Redis setup failed"
  if ! redis-cli ping | grep -q PONG; then
    error_exit "Redis health check failed"
  fi
  log "Redis setup completed"

  integrate_live_chat || error_exit "Live chat integration failed"
  configure_live_chat_backend || error_exit "Live chat backend configuration failed"
  log "Live chat setup completed"

  apply_common_features "$app_name"
  log "$app_name specifics setup completed"
}

# ---

seed_database() {
  log "Seeding database for $app_name"
  bin/rails db:seed || error_exit "Database seeding failed for $app_name"
  log "Database seeding completed for $app_name"
}

# ---

main() {
  log "Starting $app_name setup"
  initialize_app_directory
  setup_frontend_with_rails
  setup_app_specific
  seed_database
  log "$app_name setup finished"
}

main "$@"

```

## `bsdports/application.scss`
```

:root, .light_mode_link {
  --white: #ffffff;
  --black: #000000;
  --blue: #000084;
  --light-blue: #5623ee;
  --extra-light-grey: #f0f0f0;
  --light-grey: #ababab;
  --grey: #999999;
  --dark-grey: #666666;
  --warning-red: #b04243; // Federal Standard 595c
}

.dark_mode_link {
  --white: #000000;
  --black: #ffffff;
  --blue: #5623ee;
  --light-blue: #000084;
  --extra-light-grey: #666666;
  --light-grey: #999999;
  --grey: #ababab;
  --dark-grey: #f0f0f0;
}

// --

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html, body {
  height: 100%;
}

body {
  font-family: sans-serif;
  font-size: 14px;
  color: var(--black);
  background-color: var(--white);
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

a {
  color: var(--light-blue);
  text-decoration: underline;
}

header {
  display: flex;
  justify-content: right;

  .tabs {
    display: flex;
    justify-content: left;
    margin-top: 18px;
    color: var(--light-grey);
    border-bottom: 1px solid var(--extra-light-grey);

    p {
      padding: 0 3px 8px;
      margin-right: 28px;
    }

    p.active {
      color: var(--black);
      border-bottom: 1px solid var(--black);
    }
  }
}

main {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  margin: -20px 0 20px;

  .logo {
    text-indent: -9999px;
    margin: 12px 0 22px;
  }

  .logo, .logo:before {
    width: 182px;
    height: 44px;
  }

  .logo:before {
    content: "";
    position: absolute;
    background-image: url("bsdports_182x44.svg");
    background-repeat: no-repeat;
    display: block;
  }
}

#search {
  width: 90%;
  max-width: 584px;
  // background-color: var(--extra-light-grey);
  border: 1px solid var(--extra-light-grey);
  border-radius: 30px;
  font-size: 18px;
  transition: all 100ms ease-in-out;

  input {
    background: transparent;
    outline: none;
    border: none;
    width: 100%;
    padding: 16px 20px 15px;
    font-size: 16px;

    ::placeholder {
      color: var(--dark-grey);
    }
  }
}

#search {
  background-color: var(--white);
  border-color: var(--extra-light-grey);
  // box-shadow: rgba(0, 0, 0, 0.16) 0px 1px 8px 0px;

  #live_results {
    overflow: hidden;
    max-height: 220px;
    padding: 9px 19px;
    font-weight: bold;
    line-height: 29px;
    border-top: 1px solid var(--extra-light-grey);

    a {
      display: block;
    }
  }
}

.browse_link {
  margin: 44px 0 12px;
  font-size: 13px;
}

footer {
  color: var(--light-grey);
  font-size: 13px;
  display: flex;
  justify-content: center;
  align-items: stretch;

  .references {
    display: flex;
    gap: 2.6rem;
    align-items: center;
    margin-bottom: 72px;

    a {
      text-indent: -99999px;
      opacity: 0.2;
    }

    a:last-child {
      opacity: 0.3;
    }

    a:before {
      content: "";
      position: absolute;
      background-repeat: no-repeat;
      display: block;
    }

    .ror, .ror:before {
      width: 72px;
      height: 24px;
    }

    .ror:before {
      background-image: url("logo_ror_72x24.svg");
      background-position: 0 -4px;
    }

    .puma, .puma:before {
      width: 108px;
      height: 25px;
    }

    .puma:before {
      background-image: url("logo_puma_108x25.svg");
      background-position: 0 2px;
    }

    .nuug, .nuug:before {
      width: 79px;
      height: 27px;
    }

    .nuug {
      background-image: url("logo_nuug_79x27.svg");
    }

    .bergen, .bergen:before {
      width: 81px;
      height: 36px;
    }

    .bergen {
      background-image: url("logo_bergen_kommune_86x36.svg");
    }
  }

  .copyright, .dark_mode_link, .light_mode_link {
    position: absolute;
  }

  .copyright {
    left: 10px;
    bottom: 10px;
  }

  .dark_mode_link, .light_mode_link {
    position: absolute;
    bottom: 10px;
    right: 10px;
    opacity: 0.7;
  }

  .dark_mode_link span, .light_mode_link span {
    text-indent: -99999px;
  }

  .dark_mode_link:before, .light_mode_link:before {
    content: "";
    position: absolute;
    background-repeat: no-repeat;
    display: block;
  }

  .dark_mode_link:before {
    background-image: url("moon_16x16.svg");
  }

  .dark_mode_link, .dark_mode_link:before {
    width: 16px;
    height: 16px;
  }

  .light_mode_link:before {
    background-image: url("sun_20x20.svg");
  }

  .light_mode_link, .light_mode_link:before {
    width: 20px;
    height: 20px;
  }

  span {
    position: absolute;
    text-indent: -9999px;
  }
}

@media screen and (min-width: 320px) and (max-width: 480px) {
  footer {
    * {
      transform: scale(0.8);
    }

    .references {
      gap: 1.6rem;
    }

    .copyright {
      left: 0;
      bottom: 6px;
    }
  }
}

```

## `bsdports/bsdports.sh`
```
#!/usr/bin/env zsh

# -- INITIAL SETUP --

echo "Creating new Rails application..."
rails new bsdports -m https://www.rubyonrails.org

cd bsdports

echo "Adding necessary gems..."
bundle add net-ftp
bundle add rubygems-package
bundle add pry
bundle add stimulus_reflex
bundle add langchainrb
bundle add langchainrb_rails

echo "Installing gems..."
bundle install

# -- CREATE NECESSARY MODELS --

echo "Generating models..."
bin/rails generate model Category name:string platform:references
bin/rails generate model Platform name:string
bin/rails generate model Port name:string summary:text url:string description:text category:references platform:references
echo "Migrating database..."
bin/rails db:migrate

# -- CREATE SEEDS.RB --

echo "Creating seeds.rb with FTP download and database import logic..."
cat << "EOF" > db/seeds.rb
require "net/ftp"
require "rubygems/package"
require "zlib"
require "fileutils"
require "pry"

def untar(io, destination)
  Gem::Package::TarReader.new io do |tar|
    tar.each do |tarfile|
      destination_file = File.join(destination, tarfile.full_name)
      if tarfile.directory?
        FileUtils.mkdir_p(destination_file)
      else
        destination_directory = File.dirname(destination_file)
        FileUtils.mkdir_p(destination_directory) unless File.directory?(destination_directory)
        File.open(destination_file, "wb") do |f|
          f.write(tarfile.read)
        end
      end
    end
  end
end

def go_fetch(platform, server, root, tgz)
  ftp = Net::FTP.new(server)
  ftp.login
  ftp.chdir(root)
  ftp.getbinaryfile(tgz)
  ftp.close

  io = Zlib::GzipReader.open(tgz)
  untar(io, ".")

  categories = Dir.glob("./ports/*").map do |category_path|
    if File.directory?(category_path)
      category = File.basename(category_path)
      new_category = Category.find_or_create_by(name: category, platform: Platform.find_by_name(platform))
      Dir.glob("#{category_path}/*").map do |port_path|
        port = File.basename(port_path)
        description_path = "#{port_path}/pkg/DESCR"
        build_script_path = "#{port_path}/Makefile"

        description = File.exist?(description_path) ? File.read(description_path) : nil
        summary = File.exist?(build_script_path) ? File.readlines(build_script_path).find { |line| line =~ /^COMMENT/ }&.gsub("COMMENT=\t", "").strip : nil
        url = File.exist?(build_script_path) ? File.readlines(build_script_path).find { |line| line =~ /^(HOMEPAGE|WWW)/ }&.gsub("HOMEPAGE=\t", "").strip : nil

        Port.find_or_create_by(name: port, summary: summary, url: url, description: description, category: new_category)
      end
    end
  end

  FileUtils.rm_rf(Dir.glob("./ports*"))  # Cleanup
end

# Fetch ports for each platform
go_fetch("OpenBSD", "ftp.usa.openbsd.org", "/pub/OpenBSD/snapshots", "ports.tar.gz")
go_fetch("FreeBSD", "ftp.nl.freebsd.org", "/pub/FreeBSD/ports/ports", "ports.tar.gz")
go_fetch("NetBSD", "ftp.netbsd.org", "/pub/pkgsrc/stable", "pkgsrc.tar.gz")
EOF

# -- CREATE VIEWS AND SCSS --

echo "Creating views and SCSS..."
mkdir -p app/views/ports
mkdir -p app/javascript/controllers
mkdir -p app/assets/stylesheets

cat << "EOF" > app/views/ports/index.html.erb
<%= tag.h1 t("ports.index.title") %>
<%= form_with url: search_ports_path, method: :get, local: true, data: { reflex: "change->PortsReflex#search" } do |f| %>
  <%= f.text_field :query, placeholder: t("ports.index.search_placeholder") %>
<% end %>
<div id="ports_list">
  <%= render @ports %>
</div>
EOF

cat << "EOF" > app/views/ports/_port.html.erb
<div class="port">
  <%= tag.h2 port.name %>
  <%= tag.p port.summary %>
  <%= tag.p port.description %>
  <%= link_to port.url, port.url %>
</div>
EOF

cat << "EOF" > app/assets/stylesheets/application.scss
@import "variables";
@import "reset"; // Add a reset file if needed

// Light mode colors
:root {
  --white: #ffffff;
  --black: #000000;
  --blue: #000084;
  --light-blue: #5623ee;
  --extra-light-grey: #f0f0f0;
  --light-grey: #ababab;
  --grey: #999999;
  --dark-grey: #666666;
  --warning-red: #b04243; // Federal Standard 595c
}

// Dark mode colors
@media (prefers-color-scheme: dark) {
  :root {
    --white: #000000;
    --black: #ffffff;
    --blue: #5623ee;
    --light-blue: #000084;
    --extra-light-grey: #666666;
    --light-grey: #999999;
    --grey: #ababab;
    --dark-grey: #f0f0f0;
  }
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html, body {
  height: 100%;
  font-family: sans-serif;
  font-size: 14px;
  color: var(--black);
  background-color: var(--white);
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

a {
  color: var(--light-blue);
  text-decoration: underline;
}

header {
  display: flex;
  justify-content: right;

  .tabs {
    display: flex;
    margin-top: 18px;
    color: var(--light-grey);
    border-bottom: 1px solid var(--extra-light-grey);

    p {
      padding: 0 3px 8px;
      margin-right: 28px;

      &.active {
        color: var(--black);
        border-bottom: 1px solid var(--black);
      }
    }
  }
}

main {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  margin: -20px 0 20px;

  .logo {
    text-indent: -9999px;
    margin: 12px 0 22px;
    width: 182px;
    height: 44px;
    background-image: url("bsdports_182x44.svg");
    background-repeat: no-repeat;
  }
}

#search {
  width: 90%;
  max-width: 584px;
  border: 1px solid var(--extra-light-grey);
  border-radius: 30px;
  font-size: 18px;
  transition: all 100ms ease-in-out;
  display: flex;
  align-items: center;
  padding: 0 20px;

  input {
    background: transparent;
    outline: none;
    border: none;
    width: 100%;
    padding: 16px 0;
    font-size: 16px;

    &::placeholder {
      color: var(--dark-grey);
    }
  }

  #live_results {
    overflow: hidden;
    max-height: 220px;
    padding: 9px 19px;
    font-weight: bold;
    line-height: 29px;
    border-top: 1px solid var (--extra-light-grey);

    a {
      display: block;
    }
  }
}

.browse_link {
  margin: 44px 0 12px;
  font-size: 13px;
}

footer {
  color: var(--light-grey);
  font-size: 13px;
  display: flex;
  justify-content: center;
  align-items: stretch;

  .references {
    display: flex;
    gap: 2.6rem;
    align-items: center;
    margin-bottom: 72px;

    a {
      text-indent: -99999px;
      opacity: 0.2;

      &:last-child {
        opacity: 0.3;
      }

      &:before {
        content: "";
        position: absolute;
        background-repeat: no-repeat;
        display: block;
      }

      &.ror {
        width: 72px;
        height: 24px;
        background-image: url("logo_ror_72x24.svg");
        background-position: 0 -4px;
      }

      &.puma {
        width: 108px;
        height: 25px;
        background-image: url("logo_puma_108x25.svg");
        background-position: 0 2px;
      }

      &.nuug {
        width: 79px;
        height: 27px;
        background-image: url("logo_nuug_79x27.svg");
      }

      &.bergen {
        width: 81px;
        height: 36px;
        background-image: url("logo_bergen_kommune_86x36.svg");
      }
    }
  }

  .copyright, .dark_mode_link, .light_mode_link {
    position: absolute;
    bottom: 10px;
    opacity: 0.7;
  }

  .copyright {
    left: 10px;
  }

  .dark_mode_link, .light_mode_link {
    right: 10px;

    span {
      text-indent: -99999px;
    }

    &:before {
      content: "";
      position: absolute;
      background-repeat: no-repeat;
      display: block;
    }

    &.dark_mode_link {
      width: 16px;
      height: 16px;
      background-image: url("moon_16x16.svg");
    }

    &.light_mode_link {
      width: 20px;
      height: 20px;
      background-image: url("sun_20x20.svg");
    }
  }

  span {
    position: absolute;
    text-indent: -9999px;
  }
}

@media screen and (min-width: 320px) and (max-width: 480px) {
  footer {
    transform: scale(0.8);

    .references {
      gap: 1.6rem;
    }

    .copyright {
      left: 0;
      bottom: 6px;
    }
  }
}
EOF

cat << "EOF" > app/javascript/controllers/ports_controller.js
import ApplicationController from './application_controller'

export default class extends ApplicationController {
  connect() {
    this.stimulate('PortsReflex#search')
  }
}
EOF

cat << "EOF" > app/reflexes/ports_reflex.rb
class PortsReflex < ApplicationReflex
  def search
    query = params[:query].presence || ""
    @ports = Port.where("name LIKE ? OR summary LIKE ? OR description LIKE ?", "%#{query}%", "%#{query}%", "%#{query}%")
    morph "#ports_list", render(@ports)
  end
end
EOF

# -- CREATE CONTROLLER --

echo "Creating Ports controller..."
bin/rails generate controller Ports index

# -- ADD ROUTES --

echo "Adding routes..."
cat << "EOF" >> config/routes.rb
Rails.application.routes.draw do
  resources :ports, only: [:index] do
    collection do
      get :search
    end
  end
end
EOF

# -- GIT COMMITS BY FUNCTIONALITY --

echo "Initializing git repository..."
git init
git add .
git commit -m "Initialize Rails project with necessary gems and models"

# -- ADD SEEDS.RB FILE --

git add db/seeds.rb
git commit -m "Add seeds.rb file with FTP download and database import logic"

# -- ADD VIEWS, SCSS, AND STIMULUSREFLEX FUNCTIONALITY --

git add app/views/ports app/assets/stylesheets/application.scss app/javascript/controllers/ports_controller.js app/reflexes/ports_reflex.rb
git commit -m "Add views, SCSS, and live search functionality using StimulusReflex"

# -- ADD ROUTES FOR PORTS --

git add config/routes.rb
git commit -m "Add routes for ports"

# -- POPULATE DATABASE --

echo "Populating database..."
bin/rails db:seed

# -- CREATE README.MD --

cat <<EOF > README.md
# BSDports

BSDports is an advanced AI vector search database for OpenBSD, FreeBSD, NetBSD, and macOS ports. It aspires to be the premier destination for port information and serves as a testbed for the future redesign of openbsd.org.

## Features

- **Live Search**: Quickly find ports using the integrated live search functionality powered by StimulusReflex.
- **Comprehensive Port Information**: Access detailed information about each port, including summaries, descriptions, and URLs.
- **Multi-Platform Support**: Browse ports from OpenBSD, FreeBSD, NetBSD, and macOS.
- **Responsive Design**: Enjoy a consistent and optimized experience across all devices, thanks to the mobile-first design approach.
- **Dark Mode**: Experience a visually pleasing interface that adapts to your system's theme, whether light or dark.

## Installation

Follow these steps to set up the BSDports application:

1. **Clone the Repository**:
    ```sh
    git clone https://github.com/yourusername/bsdports.git
    cd bsdports
    ```

2. **Install Dependencies**:
    ```sh
    bundle install
    ```

3. **Set Up the Database**:
    ```sh
    bin/rails db:setup
    ```

4. **Start the Application**:
    ```sh
    bin/rails server
    ```

5. **Access the Application**:
    Open your browser and navigate to `http://localhost:3000`.

## Usage

### Searching for Ports

Use the search bar on the homepage to find ports quickly. The live search feature will display results as you type, making it easy to locate the ports you need.

### Browsing Ports

Explore ports by browsing through categories and platforms. Detailed information is available for each port, including descriptions and relevant URLs.

## Development

### Setting Up the Development Environment

1. **Clone the Repository**:
    ```sh
    git clone https://github.com/yourusername/bsdports.git
    cd bsdports
    ```

2. **Install Dependencies**:
    ```sh
    bundle install
    ```

3. **Set Up the Database**:
    ```sh
    bin/rails db:setup
    ```

4. **Run the Tests**:
    ```sh
    bin/rspec
    ```

### Contributing

We welcome contributions to BSDports! If you'd like to contribute, please follow these steps:

1. **Fork the Repository**:
    Click the "Fork" button at the top right of the repository page.

2. **Create a Feature Branch**:
    ```sh
    git checkout -b my-feature-branch
    ```

3. **Commit Your Changes**:
    ```sh
    git commit -m "Add my new feature"
    ```

4. **Push to the Branch**:
    ```sh
    git push origin my-feature-branch
    ```

5. **Create a Pull Request**:
    Open a pull request from your forked repository's feature branch to the main repository's master branch.

### Code of Conduct

We are committed to fostering a welcoming and inclusive community. Please read our [Code of Conduct](CODE_OF_CONDUCT.md) before contributing.

## License

BSDports is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

## Acknowledgements

This project is made possible by the contributions of many open-source libraries and the support of the community. Thank you to everyone who has helped make BSDports a success.

---

Happy porting!
EOF
git add README.md
git commit -m "Add README.md"

# -- FINAL OUTPUT --

echo "BSDports installation script completed successfully."
```

## `bsdports/import.rake`
```
require "net/ftp"
require "rubygems/package"
require "zlib"
require "fileutils"
require "pry"

namespace :import do
  task openbsd: :environment do
    go_fetch(
      "OpenBSD",
      "ftp.usa.openbsd.org",
      "/pub/OpenBSD/snapshots",
      "ports.tar.gz"
    )
  end

  task freebsd: :environment do
    go_fetch(
      "FreeBSD",
      "ftp.nl.freebsd.org",
      "/pub/FreeBSD/ports/ports",
      "ports.tar.gz"
    )
  end

  task netbsd: :environment do
    go_fetch(
      "NetBSD",
      "ftp.netbsd.org",
      "/pub/pkgsrc/stable",
      "pkgsrc.tar.gz"
    )
  end

  def untar(io, destination)
    Gem::Package::TarReader.new io do |tar|
      tar.each do |tarfile|
        destination_file = File.join destination, tarfile.full_name

        if tarfile.directory?
          FileUtils.mkdir_p destination_file
        else
          destination_directory = File.dirname(destination_file)
          FileUtils.mkdir_p destination_directory unless File.directory?(destination_directory)

          puts destination_file

          File.open destination_file, "wb" do |f|
            f.print tarfile.read
          end
        end
      end
    end
  end

  def go_fetch(platform, server, root, tgz)
    # binding.pry

    ftp = Net::FTP.new(server)
    ftp.login
    ftp.chdir(root)

    puts "Downloading #{ tgz } for #{ platform }..."

    ftp.getbinaryfile(tgz)
    ftp.close

    puts "Extracting..."

    # https://gist.github.com/sinisterchipmunk/1335041/5be4e6039d899c9b8cca41869dc6861c8eb71f13
    io = Zlib::GzipReader.open(tgz)
    untar(io, ".")

    # Cleanup folders
    if platform == ["OpenBSD", "NetBSD"]
      FileUtils.rm_rf(Dir.glob("./ports/CVS"))
      FileUtils.rm_rf(Dir.glob("./ports/*/CVS"))
    end

    if platform == "FreeBSD"
      FileUtils.rm_rf(Dir.glob("./ports/Mk"))
      FileUtils.rm_rf(Dir.glob("./ports/Templates"))
      FileUtils.rm_rf(Dir.glob("./ports/Tools"))
    end

    puts "Importing..."

    categories = Dir.glob("./ports/*").each { |category_path|
      if File.directory? category_path
        category = File.basename(category_path)

        new_category = Category.create!(
          name: category,
          platform: Platform.find_by_name(platform)
        )

        if new_category.valid?
          puts "#{ new_category.name } OK"
        end

        # binding.pry

        # Get description, summary and URL
        ports = Dir.glob("#{ category_path }/*").each { |port_path|
          port = File.basename(port_path)

          description = "#{ port_path }/pkg/DESCR"
          build_script = "#{ port_path }/Makefile"

          if File.exist?(description)
            description = File.read(description)
          end

          if File.exist?(build_script)
            summary = File.readlines(build_script).find { |line| line =~ /^COMMENT/ }
            url = File.readlines(build_script).find { |line| line =~ /^HOMEPAGE|^WWW/ }

            if summary
              summary = summary.gsub(/COMMENT=\t/, "")
              summary = summary.rstrip!
            end

            if url
              url = url.gsub(/HOMEPAGE=\t/, "")
              url = url.rstrip!
            end
          end

          # binding.pry

          new_port = Port.create!(
            name: port,
            summary: summary,
            url: url,
            description: description,
            category: Category.find_by_name(category),
            platform: Platform.find_by_name(platform)
          )

          if new_port.valid?
            puts "#{ category_path }/#{ new_port.name } OK"
          end
        }
      end
    }

    # Cleanup
    FileUtils.rm_rf(Dir.glob("./ports*"))

    if platform == "NetBSD"
      FileUtils.rm_rf(Dir.glob("./*.data"))
      FileUtils.rm_rf(Dir.glob("./*.paxheader"))
      FileUtils.rm_rf(Dir.glob("./*.pax_global_header"))
    end
  end
end

```

