class CreateDeletedTrackgoodbehaviors < ActiveRecord::Migration
  def change
    create_table :deleted_trackgoodbehaviors do |t|
      t.integer :trackgoodbehaviors_id
      t.integer :user_id
      t.string :device_id

      t.timestamps
    end
  end
end
