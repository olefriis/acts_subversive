require File.dirname(__FILE__) + '/../test_helper'

class FindByVersionTest < Test::Unit::TestCase
  fixtures :projects, :project_versions, :actors, :actor_versions
  
  def test_normal_find
    project = Project.find(1)
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
    # First version first
    actor = Actor.find_version(1, 1)
    assert_equal 'Actor in original version', actor.name
    assert_equal 1, actor.version

    # 2nd version: No change
    actor = Actor.find_version(1, 2)
    assert_equal 'Actor in original version', actor.name
    assert_equal 1, actor.version

    # 3rd version: Actor has changed name
    actor = Actor.find_version(1, 3)
    assert_equal 'Actor in newer version', actor.name
    assert_equal 3, actor.version

    # 4th version: Actor has been deleted
    actor = Actor.find_version(1, 4)
    assert_nil actor
  end
  
  def test_equality
    # Normal project
    project1 = Project.find(1)
    project2 = Project.find(1)
    assert_not_same project1, project2
    assert_equal project1, project2
    
    # Versioned project
    project1 = Project.find_version(1, 2)
    project2 = Project.find_version(1, 2)
    assert_not_same project1, project2
    assert_equal project1, project2
  end
end