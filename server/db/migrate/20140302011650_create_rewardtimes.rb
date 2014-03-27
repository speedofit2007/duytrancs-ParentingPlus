class CreateRewardtimes < ActiveRecord::Migration
  def change
    create_table :rewardtimes do |t|
      t.integer :client_id
      t.string :timeperiod
      t.integer :notebooks_id
      t.integer :notebooks_user_id
      t.string :notebooks_device_id
      t.integer :user_id
      t.string :device_id

      t.timestamps
    end
  end
end
