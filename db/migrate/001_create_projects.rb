class CreateProjects < ActiveRecord::Migration
  def self.up
    create_versioned_table :projects do |t|
      t.column :name, :text
      t.column :created_by_id, :integer
      t.column :main_use_case_id, :integer
    end
  end

  def self.down
    drop_versioned_table :projects
  end
end
