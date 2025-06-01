class AddTopicIdToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :topic_id, :integer
  end
end

