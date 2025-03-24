class AddTopicTypeToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :media, :boolean, default: false
  end
end

