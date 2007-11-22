class CreateActors < ActiveRecord::Migration
  def self.up
    create_versioned_table :actors do |t|
      t.column :project_id, :integer
      t.column :name, :text
    end
  end

  def self.down
    drop_versioned_table :actors
  end
end
