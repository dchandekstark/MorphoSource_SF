class CreateMediaCarts < ActiveRecord::Migration[5.1]
  def change
    create_table :media_carts do |t|
      t.integer :user_id, null: false
      t.index :user_id
      t.timestamps
    end
  end
end
