class CreateDeletedRewards < ActiveRecord::Migration
  def change
    create_table :deleted_rewards do |t|
      t.integer :reward_id
      t.integer :user_id
      t.string :device_id

      t.timestamps
    end
  end
end
