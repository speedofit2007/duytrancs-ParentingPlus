class CreateTokenhistories < ActiveRecord::Migration
  def change
    create_table :tokenhistories do |t|
      t.integer :client_id
      t.datetime :date
      t.integer :begin_token
      t.integer :notebooks_id
      t.integer :notebooks_user_id
      t.string :notebooks_client_id
      t.integer :user_id
      t.string :device_id

      t.timestamps
    end
  end
end
