class AddPictureSyncColumns < ActiveRecord::Migration
  def change
    add_column :notebooks, :picture, :string
    add_column :notebooks, :picture_updated, :datetime
  end
end
