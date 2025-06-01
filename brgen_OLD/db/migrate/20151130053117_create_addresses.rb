class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :place
      t.string :address
      t.string :po
      t.string :phone
      t.string :email
      t.string :url

      t.timestamps null: false
    end
  end
end

