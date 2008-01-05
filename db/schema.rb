# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 6) do

  create_table "act_versions", :force => true do |t|
    t.integer "actor_id"
    t.integer "use_case_id"
    t.integer "original_id"
    t.integer "version"
    t.boolean "deleted",     :default => false, :null => false
  end

  create_table "actor_versions", :force => true do |t|
    t.integer "project_id"
    t.text    "name"
    t.integer "original_id"
    t.integer "version"
    t.boolean "deleted",     :default => false, :null => false
  end

  create_table "actors", :force => true do |t|
    t.integer "project_id"
    t.text    "name"
  end

  create_table "acts", :force => true do |t|
    t.integer "actor_id"
    t.integer "use_case_id"
  end

  create_table "project_versions", :force => true do |t|
    t.text    "name"
    t.integer "created_by_id"
    t.integer "main_use_case_id"
    t.integer "original_id"
    t.integer "version"
    t.boolean "deleted",          :default => false, :null => false
  end

  create_table "projects", :force => true do |t|
    t.text    "name"
    t.integer "created_by_id"
    t.integer "main_use_case_id"
  end

  create_table "use_case_versions", :force => true do |t|
    t.integer "project_id"
    t.text    "name"
    t.integer "original_id"
    t.integer "version"
    t.boolean "deleted",     :default => false, :null => false
  end

  create_table "use_cases", :force => true do |t|
    t.integer "project_id"
    t.text    "name"
  end

  create_table "users", :force => true do |t|
    t.string  "name"
    t.integer "current_project_id"
  end

  create_table "version_numbers", :force => true do |t|
    t.datetime "created_at", :null => false
    t.string   "user"
  end

end
