class AddAddressToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :address, :string
  end
end

