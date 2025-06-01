class AddScraperSourceToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :scraper_source, :string
  end
end

