class AddDeviceIdToNotebooks < ActiveRecord::Migration
  def change
    remove_column :notebooks, :time_key, :timestamp
    add_column :notebooks, :device_id, :integer
  end
end
