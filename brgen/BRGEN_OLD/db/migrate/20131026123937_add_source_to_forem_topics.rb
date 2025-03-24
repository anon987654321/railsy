class AddSourceToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :source, :string
  end
end

