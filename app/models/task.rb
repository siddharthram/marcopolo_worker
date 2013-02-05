class Task < ActiveRecord::Base
  attr_accessible :xim_id
  attr_accessible :output
  attr_accessible :imageurl
  belongs_to :user

end
