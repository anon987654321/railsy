class AddDeletedAtToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :deleted_at, :datetime
  end
end

