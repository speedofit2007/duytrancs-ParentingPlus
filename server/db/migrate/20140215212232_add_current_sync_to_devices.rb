class AddCurrentSyncToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :current_sync, :timestamp
  end
end
