class AddScrapedAtToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :scraped_at, :datetime
  end
end

