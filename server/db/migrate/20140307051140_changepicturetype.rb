class Changepicturetype < ActiveRecord::Migration
  def change
    change_column :notebooks, :picture, :text
  end
end
