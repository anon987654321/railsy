class AddPasswordFieldsToForemPosts < ActiveRecord::Migration
  def change
    add_column :forem_posts, :password_hash, :string
    add_column :forem_posts, :password_salt, :string
  end
end

