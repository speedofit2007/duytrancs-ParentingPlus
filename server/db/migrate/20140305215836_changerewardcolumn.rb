class Changerewardcolumn < ActiveRecord::Migration
  def change
    rename_column :rewards, :notebooks_client_id, :notebooks_device_id
  end
end
