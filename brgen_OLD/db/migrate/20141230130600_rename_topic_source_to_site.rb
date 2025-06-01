class RenameTopicSourceToSite < ActiveRecord::Migration
  def self.up
    rename_column :forem_topics, :source, :site
  end

  def self.down
  end
end

