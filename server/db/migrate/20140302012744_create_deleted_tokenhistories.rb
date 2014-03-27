class CreateDeletedTokenhistories < ActiveRecord::Migration
  def change
    create_table :deleted_tokenhistories do |t|
      t.integer :tokenhistory_id
      t.integer :user_id
      t.string :client_id

      t.timestamps
    end
  end
end
