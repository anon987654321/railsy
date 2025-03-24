class AddFacebookIdToLike < ActiveRecord::Migration
  def change
    add_column :likes, :facebook_id, :string
  end
end

