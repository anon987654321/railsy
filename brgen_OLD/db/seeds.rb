
# Split into multiple files in `/seeds`

# http://goo.gl/l5b1GR

Dir[File.join(Rails.root, "db", "seeds", "*.rb")].sort.each { |seed| load seed }
Dir[File.join(Rails.root, "db", "seeds", "dummies", "*.rb")].sort.each { |seed| load seed }

# -------------------------------------------------

Forem::Topic.all.each do |topic|
  topic.update_column(:last_post_at, topic.posts.last.created_at)
end

# -------------------------------------------------

# Get Tor IPs

# unless File.exist?("#{Rails.root}/db/tor.db")
#   rake get_tor_ips
# end

