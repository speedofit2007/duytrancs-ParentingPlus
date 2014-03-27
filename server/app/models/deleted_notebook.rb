class DeletedNotebook < ActiveRecord::Base
  attr_accessible :device_id, :notebook_id, :user_id
end
