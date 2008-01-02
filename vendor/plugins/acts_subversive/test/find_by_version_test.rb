require "#{File.dirname(__FILE__)}/test_setup"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

class FindByVersionTest < Test::Unit::TestCase
  def setup
    setup_db

    # Version 1
    project = Project.create(:name => 'Hej med dig')

    # Version 2
    project.name = 'Hej med dig i version 2'
    project.save!

    # Version 3
    actor = Actor.create(:name => 'Actor in original version')

    # Version 4
    project.name = 'Hej med dig i sidste version'
    project.save!

    # Version 5
    project.destroy

    # Version 6
    actor.name = 'Actor in newer version'
    actor.save!

    # Version 7
    actor.destroy

    # Version 8
    Project.create(:name => 'Another project')
  end

  def teardown
    teardown_db
  end

  def test_normal_find
    project = Project.find(2)
    assert !project.versioned?
  end
  
  def test_find_project_by_version
    # First version first
    project = Project.find_version(1, 1)
    assert project.versioned?
    assert_equal 'Hej med dig', project.name
    assert_equal 1, project.version
  
    # 2nd version: Project has changed name
    project = Project.find_version(1, 2)
    assert_equal 'Hej med dig i version 2', project.name
    assert_equal 2, project.version
  
    # 3rd version: Nothing changed
    project = Project.find_version(1, 3)
    assert_equal 'Hej med dig i version 2', project.name
    assert_equal 2, project.version
  
    # 4th version: Project has changed name
    project = Project.find_version(1, 4)
    assert_equal 'Hej med dig i sidste version', project.name
    assert_equal 4, project.version
  
    # In version 5, the project has been deleted
    assert_nil Project.find_version(1, 5)
  end

  def test_find_actor_by_version
    # Version 3 first
    actor = Actor.find_version(1, 3)
    assert_equal 'Actor in original version', actor.name
    assert_equal 3, actor.version

    # Version 4: No change
    actor = Actor.find_version(1, 4)
    assert_equal 'Actor in original version', actor.name
    assert_equal 3, actor.version

    # Version 5: No change
    actor = Actor.find_version(1, 5)
    assert_equal 'Actor in original version', actor.name
    assert_equal 3, actor.version

    # Version 6: Actor has changed name
    actor = Actor.find_version(1, 6)
    assert_equal 'Actor in newer version', actor.name
    assert_equal 6, actor.version

    # Version 7: Actor has been deleted
    actor = Actor.find_version(1, 7)
    assert_nil actor
  end
  
  def test_equality
    # Normal project
    project1 = Project.find(2)
    project2 = Project.find(2)
    assert_not_same project1, project2
    assert_equal project1, project2
    
    # Versioned project
    project1 = Project.find_version(1, 2)
    project2 = Project.find_version(1, 2)
    assert_not_same project1, project2
    assert_equal project1, project2
  end
end
