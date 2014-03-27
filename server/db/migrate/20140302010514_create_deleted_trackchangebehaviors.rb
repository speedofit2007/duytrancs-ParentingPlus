class CreateDeletedTrackchangebehaviors < ActiveRecord::Migration
  def change
    create_table :deleted_trackchangebehaviors do |t|
      t.integer :trackchangebehaviors_id
      t.integer :user_id
      t.string :device_id

      t.timestamps
    end
  end
end
