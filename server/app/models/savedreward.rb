class Savedreward < ActiveRecord::Base
  attr_accessible :client_id, :date, :device_id, :notebooks_device_id, :notebooks_id, :notebooks_user_id, :rewards_client_id, :rewards_id, :rewards_status, :rewards_user_id, :user_id, :reward_name
  validates_uniqueness_of :client_id, :scope => [:device_id, :user_id]
end