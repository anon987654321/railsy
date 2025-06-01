class AddValueToForemCategories < ActiveRecord::Migration
  def change
    add_column :forem_categories, :value, :string
  end
end

