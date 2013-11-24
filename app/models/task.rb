class Task < ActiveRecord::Base
  attr_accessible :xim_id
  attr_accessible :output
  attr_accessible :imageurl
  attr_accessible :attachmentformat
  attr_accessible :isturkjob
  attr_accessible :isvalid
  belongs_to :user

end
