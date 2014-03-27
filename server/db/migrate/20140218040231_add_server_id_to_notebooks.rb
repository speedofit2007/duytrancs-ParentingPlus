class AddServerIdToNotebooks < ActiveRecord::Migration
  def change
    add_column :notebooks, :server_id, :primary_key
  end
end
