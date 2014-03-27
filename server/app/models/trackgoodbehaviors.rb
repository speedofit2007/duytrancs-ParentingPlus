class Trackgoodbehaviors < ActiveRecord::Base
  attr_accessible :client_id, :device_id, :goodbehaviors_device_id, :goodbehaviors_id, :goodbehaviors_user_id, :notebooks_device_id, :notebooks_id, :notebooks_user_id, :time1, :time2, :time3, :time4, :time_record, :user_id
  validates_uniqueness_of :client_id, :scope => [:device_id, :user_id]
end
