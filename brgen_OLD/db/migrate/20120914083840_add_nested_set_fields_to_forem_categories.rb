class AddNestedSetFieldsToForemCategories < ActiveRecord::Migration
  def change
    add_column :forem_categories, :parent_id, :integer
    add_column :forem_categories, :lft, :integer
    add_column :forem_categories, :rgt, :integer
  end
end

