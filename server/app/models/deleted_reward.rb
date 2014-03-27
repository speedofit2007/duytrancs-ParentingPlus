class DeletedReward < ActiveRecord::Base
  attr_accessible :device_id, :reward_id, :user_id
end
