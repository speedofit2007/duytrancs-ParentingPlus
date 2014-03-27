class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.integer :user_id
      t.string :device
      t.timestamp :last_sync

      t.timestamps
    end
  end
end
