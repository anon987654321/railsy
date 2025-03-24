class AddForumTypeToForemForums < ActiveRecord::Migration
  def change
    add_column :forem_forums, :forum_type, :string
  end
end

