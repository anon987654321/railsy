#!/usr/bin/env falcon-host31

load :rack

hostname = File.basename(__dir__)
port = 47284

rack hostname do
  append preload "preload.rb"
  cache false
  count ENV.fetch("FALCON_COUNT", 1).to_i
  endpoint Async::HTTP::Endpoint
    .parse("http://0.0.0.0:#{ port }")
    .with(protocol: Async::HTTP::Protocol::HTTP11)
  # .with(protocol: Async::HTTP::Protocol::HTTP2)
end

