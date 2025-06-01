class AddEnableCommentsToForemPosts < ActiveRecord::Migration
  def change
    add_column :forem_posts, :enable_comments, :boolean, default: :true
  end
end

