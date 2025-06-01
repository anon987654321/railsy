class AddForumTypeIdToForemForums < ActiveRecord::Migration
  def change
    add_column :forem_forums, :forum_type_id, :integer
  end
end

