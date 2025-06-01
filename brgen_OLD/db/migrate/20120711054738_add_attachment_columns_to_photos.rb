class AddAttachmentColumnsToPhotos < ActiveRecord::Migration
  def self.up
    change_table :photos do |t|
      t.has_attached_file :attachment
    end
  end

  def self.down
    drop_attached_file :photos, :attachment
  end
end

