class AddDeviceIdToTokenHistories < ActiveRecord::Migration
  def change
    add_column :deleted_tokenhistories, :device_id, :string
  end
end
