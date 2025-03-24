class RemoveForumTypeFromForemForums < ActiveRecord::Migration
  def up
    remove_column :forem_forums, :forum_type
  end

  def down
    add_column :forem_forums, :forum_type, :string
  end
end

