
# Autodeletes posts

# https://projects.csail.mit.edu/chanthropology/4chan.pdf

namespace :ephemerality do

  # Expire topics by setting `expired` in the database to `true`

  task :expire => :environment do
    Forem::Category.all.each do |category|
      category.expire_ads
      category.expire_events

      # Expire regular posts after 15 pages with each page containing 15 posts

      category.expire_regular_posts(15, 15)
    end
  end

  # -------------------------------------------------

  task :archive => :environment do

    # TODO: `pg_dump -Fc` for topics and http://goo.gl/2dQmiO for photos

  end

  # -------------------------------------------------

  task :delete => :environment do
    Forem::Topic.expired.update_all(state: "deleted", deleted_at: Time.current)
  end

  task :destroy => :environment do
    Forem::Topic.expired.destroy_all
  end
end 

