class CreateDeletedRewardtimes < ActiveRecord::Migration
  def change
    create_table :deleted_rewardtimes do |t|
      t.integer :rewardtime_id
      t.integer :user_id
      t.string :client_id

      t.timestamps
    end
  end
end
