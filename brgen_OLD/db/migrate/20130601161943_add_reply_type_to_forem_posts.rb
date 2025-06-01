class AddReplyTypeToForemPosts < ActiveRecord::Migration
  def change
    add_column :forem_posts, :reply_type, :string, default: "regular"
  end
end

