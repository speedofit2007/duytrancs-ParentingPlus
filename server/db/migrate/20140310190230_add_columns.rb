class AddColumns < ActiveRecord::Migration
  def change
    add_column :goodbehaviors, :date, :date
    add_column :badbehaviors, :date, :date
    add_column :changebehaviors, :date, :date
    add_column :changebehaviors, :notebooks_id, :integer
    add_column :changebehaviors, :notebooks_user_id, :integer
    add_column :changebehaviors, :notebooks_device_id, :string
  end
end
