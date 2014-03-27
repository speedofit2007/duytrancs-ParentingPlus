class RemoveIdFromNotebooks < ActiveRecord::Migration
  def change
    remove_column :notebooks, :id
  end
end
