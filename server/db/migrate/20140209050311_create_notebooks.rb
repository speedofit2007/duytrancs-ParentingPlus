class CreateNotebooks < ActiveRecord::Migration
  def change
    create_table :notebooks do |t|
      t.integer :user_id
      t.timestamp :time_key
      t.string :book_status
      t.string :book_name
      t.integer :age
      t.integer :tokens

      t.timestamps
    end
  end
end
