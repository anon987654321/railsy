class AddAnonIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :anon_id, :string
  end
end

