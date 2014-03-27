class Changetimes < ActiveRecord::Migration
  def change
    change_column :savedrewards, :date, :date
    change_column :tokenhistories, :date, :date
    change_column :trackchangebehaviors, :time_record, :date
    change_column :trackgoodbehaviors, :time_record, :date
  end
end
