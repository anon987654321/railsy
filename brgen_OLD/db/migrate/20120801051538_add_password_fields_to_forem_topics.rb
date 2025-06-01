class AddPasswordFieldsToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :password_salt, :string
    add_column :forem_topics, :password_hash, :string
  end
end

