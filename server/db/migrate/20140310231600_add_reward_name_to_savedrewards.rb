class AddRewardNameToSavedrewards < ActiveRecord::Migration
  def change
    add_column :savedrewards, :reward_name, :string
  end
end
