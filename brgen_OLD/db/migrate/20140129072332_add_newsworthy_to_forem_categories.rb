class AddNewsworthyToForemCategories < ActiveRecord::Migration
  def change
    add_column :forem_categories, :newsworthy, :boolean, default: false
  end
end

