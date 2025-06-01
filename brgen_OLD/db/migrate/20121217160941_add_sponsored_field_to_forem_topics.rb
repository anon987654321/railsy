class AddSponsoredFieldToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :sponsored, :boolean, default: false, nullable: false
  end
end

