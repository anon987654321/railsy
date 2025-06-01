class AddValueToForumTypes < ActiveRecord::Migration
  def change
    add_column :forum_types, :value, :string
  end
end

