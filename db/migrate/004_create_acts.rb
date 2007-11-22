class CreateActs < ActiveRecord::Migration
  def self.up
    create_versioned_table :acts do |t|
      t.column :actor_id, :integer
      t.column :use_case_id, :integer
    end
  end

  def self.down
    drop_versioned_table :acts
  end
end
