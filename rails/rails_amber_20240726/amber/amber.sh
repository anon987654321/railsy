#!/bin/zsh

APP="amber"
BASE_DIR="$HOME/dev/rails_apps"

# Create the application directory if it doesn't exist
mkdir -p $BASE_DIR
cd $BASE_DIR

# -- SOURCE PARTIALS --

source "$BASE_DIR/__shared/@postgresql.sh"
source "$BASE_DIR/__shared/@redis.sh"
source "$BASE_DIR/__shared/@yarn.sh"
source "$BASE_DIR/__shared/@rails_new.sh" "$APP"
source "$BASE_DIR/__shared/@devise.sh"
source "$BASE_DIR/__shared/@falcon.sh"
source "$BASE_DIR/__shared/@pwa.sh"
source "$BASE_DIR/__shared/@upload_images.sh"
source "$BASE_DIR/__shared/@ai.sh"
# source "$BASE_DIR/__shared/@posts_communities_and_comments.sh"
# source "$BASE_DIR/__shared/@kramdown_and_emojis.sh"
source "$BASE_DIR/__shared/@instant_and_private_message.sh"
source "$BASE_DIR/__shared/@live_cam_streaming.sh"
# source "$BASE_DIR/__shared/@social_media_sharing.sh"
source "$BASE_DIR/__shared/@push_notifications.sh"

# -- GENERATE MODELS --

# Set up visualizing wardrobe, style assistant, mix & match magic, fashion feed, etc.

bin/rails generate scaffold Item title:string content:text color:string size:string material:string texture:string brand:string price:decimal category:string stock_quantity:integer available:boolean sku:string release_date:date user:references
bin/rails generate scaffold Outfit name:string description:text image_url:string category:string user:references
bin/rails generate controller Search
bin/rails generate controller Home index

mkdir -p app/views/home app/views/items app/views/looks app/views/layouts app/views/pages app/views/features app/views/outfits app/views/recommendations app/views/search

cat <<EOF > app/views/layouts/application.html.erb
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="<%= form_authenticity_token %>">
    <title><%= t("site.title") %></title>
    <%= stylesheet_link_tag "application", media: "all", "data-turbo-track": "reload" %>
    <%= javascript_include_tag "application", "data-turbo-track": "reload" %>
    <%= tag.script(type: "application/ld+json") { render(partial: "shared/jsonld") } %>
  </head>
  <body>
    <%= yield %>
    <%= cable_ready_channel_tag %>
    <%= stimulus_include_tag %>
  </body>
</html>
EOF

cat <<EOF > app/views/home/_header.html.erb
<%= tag.header do %>
  <%= tag.nav do %>
    <%= image_tag("logo.svg", alt: t("brand.logo_alt")) %>
    <%= link_to t("navigation.home"), root_path %>
    <%= link_to t("features.visualize_your_wardrobe"), visualize_your_wardrobe_path %>
    <%= link_to t("features.style_assistant"), style_assistant_path %>
    <%= link_to t("features.mix_match_magic"), mix_match_magic_path %>
    <%= link_to t("features.shop_smarter"), shop_smarter_path %>
    <%= link_to t("navigation.search"), search_path %>
    <%= button_to t("navigation.login"), "#", data: { action: "dialog#open" } %>
    <%= button_to t("navigation.dark_mode"), "#", data: { action: "dark-mode#toggle" } %>
  <% end %>
<% end %>
EOF

cat <<EOF > app/views/home/_footer.html.erb
<%= tag.footer do %>
  <%= tag.section do %>
    <%= tag.h3 t("footer.about_amber") %>
    <%= tag.p t("footer.about_description") %>
  <% end %>
  <%= tag.section do %>
    <%= tag.h3 t("footer.explore") %>
    <%= link_to t("footer.special_offers"), "#" %>
    <%= link_to t("footer.ethical_practices"), "#" %>
    <%= link_to t("footer.upcoming_designers"), "#" %>
  <% end %>
  <%= tag.section do %>
    <%= tag.h3 t("footer.legal") %>
    <%= link_to t("footer.privacy_policy"), "#" %>
    <%= link_to t("footer.terms_of_service"), "#" %>
  <% end %>
  <%= tag.section do %>
    <%= tag.h3 t("footer.contact_us") %>
    <%= tag.p t("footer.contact_info") %>
    <%= link_to t("footer.email_us"), "mailto:info@amber.fashion" %>
  <% end %>
  <%= tag.section do %>
    <%= tag.h3 t("footer.supporting_wildlife") %>
    <%= tag.p t("footer.supporting_wildlife_description") %>
  <% end %>
<% end %>
EOF

# -- SET UP CONTROLLERS AND VIEWS FOR FEATURES --

cat <<EOF > app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
    @suggestions = generate_mix_and_match_suggestions(current_user.posts)
  end

  private

  def generate_mix_and_match_suggestions(posts)
    posts.sample(3)
  end
end
EOF

cat <<EOF > app/controllers/features_controller.rb
class FeaturesController < ApplicationController
  before_action :authenticate_user!

  def visualize_your_wardrobe
    @posts = current_user.posts
    # Additional logic for categorizing and organizing clothes
  end

  def style_assistant
    @outfits = current_user.outfits
  end

  def mix_match_magic
    @posts = current_user.posts
    @suggestions = generate_mix_and_match_suggestions(@posts)
  end

  def shop_smarter
    @recommendations = current_user.recommendations
  end

  private

  def generate_mix_and_match_suggestions(posts)
    posts.sample(3)
  end
end
EOF

cat <<EOF > app/controllers/outfits_controller.rb
class OutfitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_outfit, only: [:show, :edit, :update, :destroy]

  def index
    @outfits = current_user.outfits
  end

  def show
  end

  def new
    @outfit = current_user.outfits.build
  end

  def create
    @outfit = current_user.outfits.build(outfit_params)
    if @outfit.save
      redirect_to @outfit, notice: t("outfits.create.success")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @outfit.update(outfit_params)
      redirect_to @outfit, notice: t("outfits.update.success")
    else
      render :edit
    end
  end

  def destroy
    @outfit.destroy
    redirect_to outfits_url, notice: t("outfits.destroy.success")
  end

  private

  def set_outfit
    @outfit = current_user.outfits.find(params[:id])
  end

  def outfit_params
    params.require(:outfit).permit(:name, :description, post_ids: [])
  end
end
EOF

cat <<EOF > app/controllers/recommendations_controller.rb
class RecommendationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recommendation, only: [:show, :edit, :update, :destroy]

  def index
    @recommendations = current_user.recommendations
  end

  def show
  end

  def new
    @recommendation = current_user.recommendations.build
  end

  def create
    @recommendation = current_user.recommendations.build(recommendation_params)
    if @recommendation.save
      redirect_to @recommendation, notice: t("recommendations.create.success")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @recommendation.update(recommendation_params)
      redirect_to @recommendation, notice: t("recommendations.update.success")
    else
      render :edit
    end
  end

  def destroy
    @recommendation.destroy
    redirect_to recommendations_url, notice: t("recommendations.destroy.success")
  end

  private

  def set_recommendation
    @recommendation = current_user.recommendations.find(params[:id])
  end

  def recommendation_params
    params.require(:recommendation).permit(:post_id, :recommended_by)
  end
end
EOF

cat <<EOF > app/controllers/search_controller.rb
class SearchController < ApplicationController
  def index
    @query = params[:query]
    @results = if @query.present?
      Item.where("title ILIKE ?", "%\#{@query}%")
    else
      []
    end
  end
end
EOF

# -- POST VIEWS --

cat <<EOF > app/views/posts/index.html.erb
<%= tag.section do %>
  <%= tag.h1 t("posts.index.title") %>
  <%= tag.section do %>
    <% @posts.each do |post| %>
      <%= tag.section itemscope itemtype="http://schema.org/Product" do %>
        <%= link_to image_tag(post.image, data: { controller: "lightbox", action: "lightbox#open" }), post.image.url if post.image.attached? %>
        <%= tag.h2 post.title, itemprop: "name" %>
        <%= tag.p post.content, itemprop: "description" %>
        <%= link_to t("posts.index.show"), post %>
        <%= link_to t("posts.index.edit"), edit_post_path(post) %>
        <%= link_to t("posts.index.destroy"), post, method: :delete, data: { confirm: t("posts.index.confirm_destroy") } %>
      <% end %>
    <% end %>
  <% end %>
  <%= link_to t("posts.index.new_post"), new_post_path %>
<% end %>
EOF

cat <<EOF > app/views/posts/show.html.erb
<%= tag.section do %>
  <%= tag.h1 @post.title %>
  <%= tag.p @post.content %>
  <%= link_to image_tag(@post.image, data: { controller: "lightbox", action: "lightbox#open" }), @post.image.url if @post.image.attached? %>
  <%= tag.dl do %>
    <%= tag.dt t("posts.show.color") %>
    <%= tag.dd @post.color %>
    <%= tag.dt t("posts.show.size") %>
    <%= tag.dd @post.size %>
    <%= tag.dt t("posts.show.material") %>
    <%= tag.dd @post.material %>
    <%= tag.dt t("posts.show.texture") %>
    <%= tag.dd @post.texture %>
    <%= tag.dt t("posts.show.brand") %>
    <%= tag.dd @post.brand %>
    <%= tag.dt t("posts.show.price") %>
    <%= tag.dd @post.price %>
    <%= tag.dt t("posts.show.category") %>
    <%= tag.dd @post.category %>
    <%= tag.dt t("posts.show.stock_quantity") %>
    <%= tag.dd @post.stock_quantity %>
    <%= tag.dt t("posts.show.available") %>
    <%= tag.dd @post.available %>
    <%= tag.dt t("posts.show.sku") %>
    <%= tag.dd @post.sku %>
    <%= tag.dt t("posts.show.release_date") %>
    <%= tag.dd @post.release_date %>
  <% end %>
  <%= link_to t("posts.show.edit"), edit_post_path(@post) %>
  <%= link_to t("posts.show.back"), posts_path %>
<% end %>
EOF

cat <<EOF > app/views/posts/new.html.erb
<%= tag.section do %>
  <%= tag.h1 t("posts.new.title") %>
  <%= render "form", post: @post %>
  <%= link_to t("posts.new.back"), posts_path %>
<% end %>
EOF

cat <<EOF > app/views/posts/edit.html.erb
<%= tag.section do %>
  <%= tag.h1 t("posts.edit.title") %>
  <%= render "form", post: @post %>
  <%= link_to t("posts.edit.back"), posts_path %>
<% end %>
EOF

cat <<EOF > app/views/posts/_form.html.erb
<%= form_with(model: post, local: true, data: { controller: "validation character_counter" }) do |form| %>
  <% if post.errors.any? %>
    <%= tag.h2 do %>
      <%= pluralize(post.errors.count, "error") %> <%= t("posts.form.errors") %>
    <% end %>
    <%= tag.ul do %>
      <% post.errors.full_messages.each do |message| %>
        <%= tag.li message %>
      <% end %>
    <% end %>
  <% end %>
  <%= tag.div do %>
    <%= form.label :title %>
    <%= form.text_field :title, data: { action: "input->character_counter#count" } %>
    <%= tag.span data: { character_counter_target: "counter" } %>
  <% end %>
  <%= tag.div do %>
    <%= form.label :content %>
    <%= form.text_area :content %>
  <% end %>
  <%= tag.div do %>
    <%= form.label :image %>
    <%= form.file_field :image %>
  <% end %>
  <%= tag.div do %>
    <%= form.label :color %>
    <%= form.text_field :color %>
  <% end %>
  <%= tag.div do %>
    <%= form.label :size %>
    <%= form.text_field :size %>
  <% end %>
  <%= tag.div do %>
    <%= form.label :material %>
    <%= form.text_field :material %>
  <% end %>
  <%= tag.div do %>
    <%= form.label :texture %>
    <%= form.text_field :texture %>
  <% end %>
  <%= tag.div do %>
    <%= form.label :brand %>
    <%= form.text_field :brand %>
  <% end %>
  <%= tag.div do %>
    <%= form.label :price %>
    <%= form.text_field :price %>
  <% end %>
  <%= tag.div do %>
    <%= form.label :category %>
    <%= form.text_field :category %>
  <% end %>
  <%= tag.div do %>
    <%= form.label :stock_quantity %>
    <%= form.number_field :stock_quantity %>
  <% end %>
  <%= tag.div do %>
    <%= form.label :available %>
    <%= form.check_box :available %>
  <% end %>
  <%= tag.div do %>
    <%= form.label :sku %>
    <%= form.text_field :sku, data: { controller: "masked_input", masked_input_pattern: "\\\\d{3}-\\\\d{2}-\\\\d{4}" } %>
  <% end %>
  <%= tag.div do %>
    <%= form.label :release_date %>
    <%= form.date_select :release_date %>
  <% end %>
  <%= tag.div do %>
    <%= form.submit %>
  <% end %>
<% end %>
EOF

# -- SET UP I18N --

mkdir -p config/locales
cat <<EOF > config/locales/en.yml
en:
  site:
    title: "Amber"
  brand:
    logo_alt: "Amber Logo"
  navigation:
    home: "Home"
    search: "Search"
    login: "Login"
    dark_mode: "Dark Mode"
  features:
    visualize_your_wardrobe: "Visualize Your Wardrobe"
    style_assistant: "Style Assistant"
    mix_match_magic: "Mix & Match Magic"
    fashion_feed: "Fashion Feed"
    shop_smarter: "Shop Smarter"
  footer:
    about_amber: "About Amber"
    about_description: "Amber is an AI-enhanced social network for fashion."
    explore: "Explore"
    special_offers: "Special Offers"
    ethical_practices: "Ethical Practices"
    upcoming_designers: "Upcoming Designers"
    legal: "Legal"
    privacy_policy: "Privacy Policy"
    terms_of_service: "Terms of Service"
    contact_us: "Contact Us"
    contact_info: "For any inquiries, feel free to reach us at:"
    email_us: "Email Us"
    supporting_wildlife: "Supporting Wildlife"
    supporting_wildlife_description: "We are committed to protecting wildlife through our sustainable practices and ethical fashion choices."
EOF

cat <<EOF > config/locales/no.yml
no:
  site:
    title: "Amber"
  brand:
    logo_alt: "Amber Logo"
  navigation:
    home: "Hjem"
    search: "Søk"
    login: "Logg Inn"
    dark_mode: "Mørk Modus"
  features:
    visualize_your_wardrobe: "Visualiser Garderoben Din"
    style_assistant: "Stilassistent"
    mix_match_magic: "Mix & Match Magi"
    fashion_feed: "Mote Nyheter"
    shop_smarter: "Handle Smartere"
  footer:
    about_amber: "Om Amber"
    about_description: "Amber er et AI-forbedret sosialt nettverk for mote."
    explore: "Utforsk"
    special_offers: "Spesialtilbud"
    ethical_practices: "Etiske Praksiser"
    upcoming_designers: "Kommende Designere"
    legal: "Juridisk"
    privacy_policy: "Personvernpolicy"
    terms_of_service: "Vilkår for Bruk"
    contact_us: "Kontakt Oss"
    contact_info: "For alle henvendelser, vennligst kontakt oss på:"
    email_us: "Send en epost"
    supporting_wildlife: "Støtte Dyreliv"
    supporting_wildlife_description: "Vi er forpliktet til å beskytte dyrelivet gjennom våre bærekraftige praksiser og etiske motevalg."
EOF

echo "Amber setup complete."
