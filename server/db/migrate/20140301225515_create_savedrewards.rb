class CreateSavedrewards < ActiveRecord::Migration
  def change
    create_table :savedrewards do |t|
      t.integer :client_id
      t.integer :notebooks_id
      t.integer :notebooks_user_id
      t.string :notebooks_device_id
      t.integer :rewards_id
      t.integer :rewards_user_id
      t.string :rewards_client_id
      t.string :rewards_status
      t.datetime :date
      t.integer :user_id
      t.string :device_id

      t.timestamps
    end
  end
end
