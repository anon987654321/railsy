class AddEmailToForemPost < ActiveRecord::Migration
  def change
    add_column :forem_posts, :email, :string
  end
end

