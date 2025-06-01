
brgen_home="/home/www/brgen"

# -------------------------------------------------

path+=( ${brgen_home}/bin )

# -------------------------------------------------

source ${brgen_home}/.apikeys

# -------------------------------------------------

alias back_soft="git reset --soft HEAD~1"
alias back_hard="git reset --hard HEAD~1"

# -------------------------------------------------

# By default `rails s` binds to `localhost` which won't work on VMs
 
# http://edgeguides.rubyonrails.org/4_2_release_notes.html#default-host-for-rails-server

alias rs="rails s -b 0.0.0.0"

# -------------------------------------------------

alias brgen_start="/etc/rc.d/brgen start"
alias brgen_stop="/etc/rc.d/brgen stop"

# -------------------------------------------------

# Don't prompt for verification on `rm -rf`

setopt rmstarsilent

brgen_pull() {
  brgen_stop
  cd ${brgen_home} &&
  # rm -rf public/assets/*
  git pull &&
  bundle update &&
  bundle exec rake db:migrate RAILS_ENV=production &&
  bundle exec rake assets:precompile RAILS_ENV=production &&
  # bundle exec rake i18n:js:export &&
  brgen_start
}

brgen_pull_reset() {
  brgen_stop
  cd ${brgen_home} &&
  rm -rf public/assets/* log/*.log log/puma/*.log
  sudo rm -rf public/system/*
  git pull &&
  bundle update &&
  # bundle exec rake forem:install:migrations &&
  bundle exec rake db:reset RAILS_ENV=production &&
  bundle exec rake assets:precompile RAILS_ENV=production &&
  bundle exec rake i18n:js:export &&
  brgen_start
}

