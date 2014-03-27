class Changepicturetypelimit < ActiveRecord::Migration
  def change
    change_column :notebooks, :picture, :text, :limit => 4294967296
  end
end
