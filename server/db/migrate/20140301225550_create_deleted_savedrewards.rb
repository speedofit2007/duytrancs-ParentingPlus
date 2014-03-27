class CreateDeletedSavedrewards < ActiveRecord::Migration
  def change
    create_table :deleted_savedrewards do |t|
      t.integer :savedreward_id
      t.integer :user_id
      t.string :device_id

      t.timestamps
    end
  end
end
