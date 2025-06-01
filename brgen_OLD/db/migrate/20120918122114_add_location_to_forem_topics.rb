class AddLocationToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :location, :string
  end
end

