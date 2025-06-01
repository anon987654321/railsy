class AddNestedSetFieldsToForemPosts < ActiveRecord::Migration
  def change
    # We will be using :reply_to_id as :parent_id
    # add_column :forem_posts, :parent_id, :integer
    add_column :forem_posts, :lft, :integer
    add_column :forem_posts, :rgt, :integer
  end
end

