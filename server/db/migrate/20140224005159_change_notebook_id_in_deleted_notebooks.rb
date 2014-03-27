class ChangeNotebookIdInDeletedNotebooks < ActiveRecord::Migration
  def change
    change_column :deleted_notebooks, :notebook_id, :string
  end
end
