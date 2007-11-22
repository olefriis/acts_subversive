class CreateUseCases < ActiveRecord::Migration
  def self.up
    create_versioned_table :use_cases do |t|
      t.column :project_id, :integer
      t.column :name, :text
    end
  end

  def self.down
    drop_versioned_table :use_cases
  end
end
