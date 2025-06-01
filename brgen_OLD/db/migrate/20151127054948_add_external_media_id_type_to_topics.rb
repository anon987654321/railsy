class AddExternalMediaIdTypeToTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :external_media_id, :string
    add_column :forem_topics, :external_media_type, :string
  end
end

