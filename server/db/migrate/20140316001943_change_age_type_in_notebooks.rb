class ChangeAgeTypeInNotebooks < ActiveRecord::Migration
  def change
    change_column :notebooks, :age, :date
  end
end
