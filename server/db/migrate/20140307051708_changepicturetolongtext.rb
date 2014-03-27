class Changepicturetolongtext < ActiveRecord::Migration
  def change
    change_column :notebooks, :picture, :longtext
  end
end
