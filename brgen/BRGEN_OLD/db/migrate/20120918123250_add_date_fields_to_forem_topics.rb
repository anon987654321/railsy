class AddDateFieldsToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :start_date, :datetime
    add_column :forem_topics, :end_date, :datetime
  end
end

