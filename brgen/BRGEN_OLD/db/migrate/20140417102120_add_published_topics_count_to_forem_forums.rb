class AddPublishedTopicsCountToForemForums < ActiveRecord::Migration
  def change
    add_column :forem_forums, :published_topics_count, :integer, default: 0, null: false
  end
end

