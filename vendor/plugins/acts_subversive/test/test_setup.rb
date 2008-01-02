require 'test/unit'

require 'rubygems'
gem 'activerecord', '>= 1.15.4.7794'
require 'active_record'
require 'active_record/fixtures'

require "#{File.dirname(__FILE__)}/../init"
require "#{File.dirname(__FILE__)}/../tasks/tasks"
require "#{File.dirname(__FILE__)}/database_setup"
require "#{File.dirname(__FILE__)}/model_classes"

