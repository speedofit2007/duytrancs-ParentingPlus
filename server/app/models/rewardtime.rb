class Rewardtime < ActiveRecord::Base
  attr_accessible :client_id, :device_id, :notebooks_device_id, :notebooks_id, :notebooks_user_id, :timeperiod, :user_id
    validates_uniqueness_of :client_id, :scope => [:device_id, :user_id]
end
