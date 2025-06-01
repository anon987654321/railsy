class AddCatsOrDogsToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :cats_or_dogs, :boolean
  end
end

