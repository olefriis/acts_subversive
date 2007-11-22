class Act < ActiveRecord::Base
  acts_subversive
  
  belongs_to :actor
  belongs_to :use_case
end
