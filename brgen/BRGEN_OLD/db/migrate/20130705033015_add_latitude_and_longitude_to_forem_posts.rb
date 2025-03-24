class AddGenderCodeIdToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :integer
  end
end

class AddLatitudeAndLongitudeToForemPosts < ActiveRecord::Migration
  def change
    add_column :forem_posts, :latitude, :float
    add_column :forem_posts, :longitude, :float
  end
end

