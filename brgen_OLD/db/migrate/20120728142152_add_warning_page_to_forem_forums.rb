class AddWarningPageToForemForums < ActiveRecord::Migration
  def change
    add_column :forem_forums, :notice_page, :string
  end
end

