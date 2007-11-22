class Actor < ActiveRecord::Base
  acts_subversive

  belongs_to :project
  has_many :acts, :dependent => :destroy
  has_many :use_cases, :through => :acts
end
