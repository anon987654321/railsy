class AddScrapedAtToForemPosts < ActiveRecord::Migration
  def change
    add_column :forem_posts, :scraped_at, :datetime
  end
end

