class Reward < ActiveRecord::Base
  attr_accessible :client_id, :device_id, :notebooks_client_id, :notebooks_id, :notebooks_user_id, :notebooks_device_id, :price, :reward_name, :user_id
    validates_uniqueness_of :client_id, :scope => [:device_id, :user_id]
end
