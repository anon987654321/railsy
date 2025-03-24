class CreateForumTypes < ActiveRecord::Migration
  def change
    create_table :forum_types do |t|
      t.string :name

      t.timestamps
    end
  end
end

