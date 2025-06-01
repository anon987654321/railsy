class AddViewsCountToForemCategories < ActiveRecord::Migration
  def up
    add_column :forem_categories, :views_count, :integer, :default=>0

    Forem::Category.find_each do |category|
      category.update_column(:views_count, category.views.sum(:count))
    end
  end

  def down
    remove_column :forem_categories, :views_count, :integer, :default=>0
  end
end

