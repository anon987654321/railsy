class AddFacebookIdToForemPosts < ActiveRecord::Migration
  def change
    add_column :forem_posts, :facebook_id, :string
  end
end

