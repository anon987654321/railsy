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
