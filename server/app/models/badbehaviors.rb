class Badbehaviors < ActiveRecord::Base
  attr_accessible :client_id, :device_id, :name, :notebooks_device_id, :notebooks_id, :notebooks_user_id, :reminders, :user_id, :date
    validates_uniqueness_of :client_id, :scope => [:device_id, :user_id]
end
