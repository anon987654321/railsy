class AddScraperFieldsToForemPosts < ActiveRecord::Migration
  def change
    add_column :forem_posts, :scraped_post_id, :string
    add_column :forem_posts, :reply_to_scraped_post_id, :string
    add_column :forem_posts, :poster, :string
  end
end

