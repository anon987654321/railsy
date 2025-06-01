class CreateSubscriptions < ActiveRecord::Migration
  def change

    create_table 'subscriptions', force: :cascade do |t|
      t.integer 'source_id', null: false
      t.string 'object_type', null: false
      t.string 'object_name'
      t.decimal 'max_tag_id', precision: 40
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.decimal 'latitude', precision: 11, scale: 8
      t.decimal 'longitude', precision: 11, scale: 8
      t.integer 'radius'
    end

  end
end

