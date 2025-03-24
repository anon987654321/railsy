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
