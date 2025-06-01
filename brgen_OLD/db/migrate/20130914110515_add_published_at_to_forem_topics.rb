class AddPublishedAtToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :published_at, :datetime
  end
end

