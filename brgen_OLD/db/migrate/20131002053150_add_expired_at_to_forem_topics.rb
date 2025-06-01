class AddExpiredAtToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :expired_at, :datetime
  end
end

