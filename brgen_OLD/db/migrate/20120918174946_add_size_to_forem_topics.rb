class AddSizeToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :size, :decimal
  end
end

