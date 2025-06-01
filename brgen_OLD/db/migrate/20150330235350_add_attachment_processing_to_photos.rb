class AddAttachmentProcessingToPhotos < ActiveRecord::Migration
  def self.up
    change_table :photos do |t|
      t.column :attachment_processing, :boolean, default: false
    end
  end

  def self.down
    change_table :photos do |t|
      t.remove :attachment_processing
    end
  end
end

