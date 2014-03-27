class Changetrackgoodbehaviors < ActiveRecord::Migration
  def change
    change_column :trackgoodbehaviors, :time_record, :date
  end
end
