class Trackchangebehaviors < ActiveRecord::Base
  attr_accessible :changebehaviors_device_id, :changebehaviors_id, :changebehaviors_user_id, :client_id, :device_id, :notebooks_device_id, :notebooks_id, :notebooks_user_id, :time1, :time2, :time3, :time4, :time_record, :user_id
  validates_uniqueness_of :client_id, :scope => [:device_id, :user_id]
end
