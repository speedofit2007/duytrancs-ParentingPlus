class CreateDeletedBadbehaviors < ActiveRecord::Migration
  def change
    create_table :deleted_badbehaviors do |t|
      t.integer :badbehaviors_id
      t.integer :user_id
      t.string :device_id

      t.timestamps
    end
  end
end
