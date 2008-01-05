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