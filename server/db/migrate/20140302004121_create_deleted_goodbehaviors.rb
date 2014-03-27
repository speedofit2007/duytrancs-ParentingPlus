class CreateDeletedGoodbehaviors < ActiveRecord::Migration
  def change
    create_table :deleted_goodbehaviors do |t|
      t.integer :goodbehaviors_id
      t.integer :user_id
      t.string :device_id

      t.timestamps
    end
  end
end
