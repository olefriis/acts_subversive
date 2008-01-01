# Creates new methods:
# - create_versioned_table
# - drop_versioned_table
#
# These methods work like the normal "create_table" and "drop_table", except they create/drop
# also a version table. For example,
#   create_versioned_table :users do |t| ... end
# will create the users table as normal, but will also create a table named "user_versions"
# with the same columns as the users table, in addition to these columns:
# - original_id  (the id of the original object)
# - version      (version number for this version instance)
# - deleted      (true if this version is the deletion of the entity)
#
# dop_versioned_table simply drops both the normal table and the versioned table.
require 'tasks.rb'

