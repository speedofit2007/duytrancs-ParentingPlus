class AddIdToNotebooks < ActiveRecord::Migration
  def change
    add_column :notebooks, :id, :integer
  end
end
