class User < ActiveRecord::Base
  belongs_to :current_project, :class_name => 'Project', :foreign_key => 'current_project_id'
end
