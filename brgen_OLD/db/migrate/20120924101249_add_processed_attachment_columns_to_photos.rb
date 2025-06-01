class AddProcessedAttachmentColumnsToPhotos < ActiveRecord::Migration
  def self.up
    change_table :photos do |t|
      t.has_attached_file :processed_attachment
    end
  end

  def self.down
    drop_attached_file :photos, :processed_attachment
  end
end

