class AddFilterDataToPhotos < ActiveRecord::Migration
  def up
    change_table :photos do |t|
      t.column :filter_data, :text
    end
  end

  def down
    change_table :photos do |t|
      t.remove :filter_data
    end
  end
end

