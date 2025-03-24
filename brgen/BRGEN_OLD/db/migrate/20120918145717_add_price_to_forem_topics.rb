class AddPriceToForemTopics < ActiveRecord::Migration
  def change
    add_column :forem_topics, :price, :decimal, precision: 8, scale: 2
  end
end

