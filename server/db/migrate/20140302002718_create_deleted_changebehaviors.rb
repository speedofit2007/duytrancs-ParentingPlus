class CreateDeletedChangebehaviors < ActiveRecord::Migration
  def change
    create_table :deleted_changebehaviors do |t|
      t.integer :changebehaviors_id
      t.integer :user_id
      t.string :device_id

      t.timestamps
    end
  end
end
