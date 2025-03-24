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

