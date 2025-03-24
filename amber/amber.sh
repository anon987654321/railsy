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

