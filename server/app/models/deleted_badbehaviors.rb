class DeletedBadbehaviors < ActiveRecord::Base
  attr_accessible :badbehaviors_id, :device_id, :user_id
end
