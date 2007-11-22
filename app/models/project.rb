class Project < ActiveRecord::Base
  acts_subversive
  
  # Various associations to versioned classes
  has_many :use_cases
  has_many :actors
  belongs_to :main_use_case, :class_name => 'UseCase', :foreign_key => 'main_use_case_id'

  # Associations to unversioned class
  has_many :current_users, :class_name => 'User', :foreign_key => 'current_project_id'
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
end
