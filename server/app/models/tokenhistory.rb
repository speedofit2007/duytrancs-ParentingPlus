class Tokenhistory < ActiveRecord::Base
  attr_accessible :begin_token, :client_id, :date, :device_id, :notebooks_client_id, :notebooks_id, :notebooks_user_id, :user_id
  validates_uniqueness_of :client_id, :scope => [:device_id, :user_id]
end
