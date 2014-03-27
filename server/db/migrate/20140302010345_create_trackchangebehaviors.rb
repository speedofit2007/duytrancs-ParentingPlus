class CreateTrackchangebehaviors < ActiveRecord::Migration
  def change
    create_table :trackchangebehaviors do |t|
      t.integer :client_id
      t.datetime :time_record
      t.integer :notebooks_id
      t.integer :notebooks_user_id
      t.string :notebooks_device_id
      t.integer :changebehaviors_id
      t.integer :changebehaviors_user_id
      t.string :changebehaviors_device_id
      t.string :time1
      t.string :time2
      t.string :time3
      t.string :time4
      t.integer :user_id
      t.string :device_id

      t.timestamps
    end
  end
end
