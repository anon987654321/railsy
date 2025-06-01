class AddNumberToForemPost < ActiveRecord::Migration
  def change
    add_column :forem_posts, :number, :string
  end
end

