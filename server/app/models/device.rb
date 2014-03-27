class Device < ActiveRecord::Base
  attr_accessible :device, :last_sync, :user_id, :current_sync
end
