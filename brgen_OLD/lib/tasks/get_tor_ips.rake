task :get_tor_ips do
  system("wget -q https://dan.me.uk/torlist/ -O #{Rails.root}/db/tor.db")
end

