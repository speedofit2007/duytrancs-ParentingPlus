class AddDeviceIdToDeletedRewardtimes < ActiveRecord::Migration
  def change
    add_column :deleted_rewardtimes, :device_id, :string
  end
end
