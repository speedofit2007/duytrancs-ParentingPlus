class ChangeNotebooksDeviceId < ActiveRecord::Migration
  def change
    change_column :notebooks, :device_id, :string
  end
end
