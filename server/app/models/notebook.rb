class Notebook < ActiveRecord::Base
  attr_accessible :id, :age, :book_name, :book_status, :device_id, :tokens, :user_id, :client_id
  validates_uniqueness_of :client_id, :scope => [:device_id, :user_id]
end
