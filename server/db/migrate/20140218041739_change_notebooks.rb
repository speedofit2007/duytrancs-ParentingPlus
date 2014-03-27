class ChangeNotebooks < ActiveRecord::Migration
  def change
    remove_column :notebooks, :server_id
    remove_column :notebooks, :id
    add_column :notebooks, :id, :primary_key
    add_column :notebooks, :client_id, :integer
  end
end
