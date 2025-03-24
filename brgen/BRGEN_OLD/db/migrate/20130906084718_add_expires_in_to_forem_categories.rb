class AddExpiresInToForemCategories < ActiveRecord::Migration
  def change
    add_column :forem_categories, :expires_in, :integer
  end
end

