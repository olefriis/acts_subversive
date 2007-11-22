class CreateVersionNumbers < ActiveRecord::Migration
  def self.up
    create_table :version_numbers do |t|
      t.column :created_at, :timestamp, :null => false
      t.column :user, :string
    end
  end

  def self.down
    drop_table :version_numbers
  end
end
