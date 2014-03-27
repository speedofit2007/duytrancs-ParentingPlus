class CreateChangebehaviors < ActiveRecord::Migration
  def change
    create_table :changebehaviors do |t|
      t.integer :client_id
      t.string :badbh_id
      t.integer :badbh_user_id
      t.string :badbh_device_id
      t.string :bhname
      t.integer :user_id
      t.string :device_id

      t.timestamps
    end
  end
end
