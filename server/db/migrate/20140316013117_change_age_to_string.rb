class ChangeAgeToString < ActiveRecord::Migration
  def change
    change_column :notebooks, :age, :string
  end
end
