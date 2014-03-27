class CreateDeletedNotebooks < ActiveRecord::Migration
  def change
    create_table :deleted_notebooks do |t|
      t.integer :device_id
      t.integer :user_id
      t.integer :notebook_id

      t.timestamps
    end
  end
end
