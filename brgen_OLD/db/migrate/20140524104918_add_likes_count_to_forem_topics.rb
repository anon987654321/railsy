class AddLikesCountToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :likes_count, :integer, default: 0
  end
end

