class Goodbehaviors < ActiveRecord::Base
  attr_accessible :bhname, :client_id, :device_id, :notebooks_device_id, :notebooks_id, :notebooks_user_id, :user_id, :date
    validates_uniqueness_of :client_id, :scope => [:device_id, :user_id]
end
