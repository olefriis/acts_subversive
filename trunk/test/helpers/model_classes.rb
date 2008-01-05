# We don't have ActiveSupport's dependency fetching working in the
# test, so we need to first declare our classes, then fill out the
# contents afterwards.

class Project < ActiveRecord::Base
  acts_subversive
end

class UseCase < ActiveRecord::Base
  acts_subversive
end

class Actor < ActiveRecord::Base
  acts_subversive
end

class Act < ActiveRecord::Base
  acts_subversive
end

class User < ActiveRecord::Base
end

class Project
  # Various associations to versioned classes
  has_many :use_cases
  has_many :actors
  belongs_to :main_use_case, :class_name => 'UseCase', :foreign_key => 'main_use_case_id'

  # Associations to unversioned class
  has_many :current_users, :class_name => 'User', :foreign_key => 'current_project_id'
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
end

class UseCase
  belongs_to :project
  has_many :acts
  has_many :actors, :through => :acts
end

class Actor
  belongs_to :project
  has_many :acts, :dependent => :destroy
  has_many :use_cases, :through => :acts
end

class Act
  belongs_to :actor
  belongs_to :use_case
end

class User
  belongs_to :current_project, :class_name => 'Project', :foreign_key => 'current_project_id'
end
