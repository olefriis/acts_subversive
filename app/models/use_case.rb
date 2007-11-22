class UseCase < ActiveRecord::Base
  acts_subversive
  
  belongs_to :project
  has_many :acts
  has_many :actors, :through => :acts
end
