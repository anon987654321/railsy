class CreatePorts < ActiveRecord::Migration[7.0]
  def change
    create_table :ports do |t|
      t.string :name
      t.string :summary
      t.string :url
      t.text :description
      t.string :author
      t.references :category, null: false, foreign_key: true
      t.references :platform, null: false, foreign_key: true

      t.timestamps
    end
  end
end

