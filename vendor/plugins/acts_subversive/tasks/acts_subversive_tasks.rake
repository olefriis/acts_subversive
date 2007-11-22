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
require 'active_record/connection_adapters/abstract/schema_definitions.rb'
require 'active_record/connection_adapters/abstract/schema_statements.rb'
class ActiveRecord::ConnectionAdapters::TableDefinition
  alias_method :subversive_column, :column    
end
module ActiveRecord::ConnectionAdapters::SchemaStatements
  def create_versioned_table(name, options = {}, &block)
    create_table name, options, &block
    create_table version_table_name(name) do |t|
      def t.column(name, type, options = {})
        options.delete :references
        subversive_column name, type, options
      end
      yield t
      t.column :original_id, :integer
      t.column :version, :integer
      t.column :deleted, :boolean, :null => false, :default => 0
    end
  end
  
  def drop_versioned_table(name, options = {})
      drop_table name, options
      drop_table version_table_name(name), options
  end
  
  def create_version_number_table
    create_table :version_numbers do |t|
      t.column :created_at, :timestamp, :null => false
      t.column :user, :string
    end
  end
  
  def drop_version_number_table
    drop_table :version_numbers
  end
  
  def version_table_name(table_name)
    table_name.singularize + '_versions'
  end
end