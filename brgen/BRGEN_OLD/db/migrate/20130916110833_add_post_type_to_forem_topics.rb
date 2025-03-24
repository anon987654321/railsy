class AddPostTypeToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :post_type, :string
  end
end

