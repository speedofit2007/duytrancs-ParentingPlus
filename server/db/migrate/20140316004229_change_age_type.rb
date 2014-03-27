class ChangeAgeType < ActiveRecord::Migration
  def change
    change_column :notebooks, :age, :datetime
  end
end
