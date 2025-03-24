class AddFacebookIdToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :facebook_id, :string
  end
end

