class Fixrewardscolumn < ActiveRecord::Migration
  def change
    rename_column :tokenhistories, :notebooks_client_id, :notebooks_device_id
  end
end
