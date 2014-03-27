class Changebehaviors < ActiveRecord::Base
  attr_accessible :badbh_device_id, :badbh_id, :badbh_user_id, :bhname, :client_id, :device_id, :user_id, :date, :notebooks_id, :notebooks_user_id, :notebooks_device_id
    validates_uniqueness_of :client_id, :scope => [:device_id, :user_id]
end
