class AddAdConfirmationKeyToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :ad_confirmation_key, :string
  end
end

