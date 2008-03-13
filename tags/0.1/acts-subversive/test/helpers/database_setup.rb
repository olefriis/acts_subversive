def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_version_number_table

    create_versioned_table :projects do |t|
      t.column :name, :text
      t.column :created_by_id, :integer
      t.column :main_use_case_id, :integer
    end

    create_versioned_table :use_cases do |t|
      t.column :project_id, :integer
      t.column :name, :text
    end

    create_versioned_table :actors do |t|
      t.column :project_id, :integer
      t.column :name, :text
    end

    create_versioned_table :acts do |t|
      t.column :actor_id, :integer
      t.column :use_case_id, :integer
    end

    create_table :users do |t|
      t.column :name, :string
      t.column :current_project_id, :integer
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end
