class DeletedTokenhistory < ActiveRecord::Base
  attr_accessible :client_id, :tokenhistory_id, :user_id
end
