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
