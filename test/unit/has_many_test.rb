require File.dirname(__FILE__) + '/../test_helper'

class HasManyTest < Test::Unit::TestCase
  fixtures :projects, :project_versions, :actors, :actor_versions, :acts, :act_versions, :use_cases, :use_case_versions, :users

  def test_has_many
    # First version first
    project = Project.find_version(1, 1)
    assert_equal 2, project.actors.size
    assert_equal 'Actor in original version', project.actors[0].name
    assert_equal 'Other actor in original version', project.actors[1].name

    # 2nd version: One actor has changed name
    project = Project.find_version(1, 2)
    assert_equal 2, project.actors.size
    assert_equal 'Actor in original version', project.actors[0].name
    assert_equal 'Other actor in newer version', project.actors[1].name

    # 3rd version: Another actor has changed name
    project = Project.find_version(1, 3)
    assert_equal 2, project.actors.size
    assert_equal 'Actor in newer version', project.actors[0].name
    assert_equal 'Other actor in newer version', project.actors[1].name

    # 4th version: An actor has been deleted
    project = Project.find_version(1, 4)
    assert_equal 1, project.actors.size
    assert_equal 'Other actor in newer version', project.actors[0].name
  end

  # The "force_reload" parameter must work
  def test_force_reload
    project = Project.find_version(1, 2)
    first_actor = project.actors[0]
    second_actor = project.actors[0]
    assert_same first_actor, second_actor
    
    not_reloaded_actor = project.actors(false)[0]
    assert_same first_actor, not_reloaded_actor
    
    reloaded_actor = project.actors(true)[0]
    assert_not_same first_actor, reloaded_actor
    assert_equal first_actor, reloaded_actor
  end
  
  # We need to make sure that we haven't messed up the "force_reload" parameter
  # for unversioned objects.
  def test_force_reload_normally
    project = Project.find 1
    first_actor = project.actors[0]
    second_actor = project.actors[0]
    assert_same first_actor, second_actor
    
    not_reloaded_actor = project.actors(false)[0]
    assert_same first_actor, not_reloaded_actor
    
    reloaded_actor = project.actors(true)[0]
    assert_not_same first_actor, reloaded_actor
    assert_not_same first_actor, reloaded_actor
    assert_equal first_actor, reloaded_actor
  end

  # The "force_reload" parameter must work when we have specified the :through
  # option.
  def test_force_reload_through
    actor = Actor.find_version(40, 2)
    first_use_case = actor.use_cases[0]
    second_use_case = actor.use_cases[0]
    assert_same first_use_case, second_use_case
    
    not_reloaded_use_case = actor.use_cases(false)[0]
    assert_same first_use_case, not_reloaded_use_case
    
    reloaded_use_case = actor.use_cases(true)[0]
    assert_not_same first_use_case, reloaded_use_case
    assert_not_same first_use_case, reloaded_use_case
    assert_equal first_use_case, reloaded_use_case
  end
  
  # We need to make sure that we haven't messed up the "force_reload" parameter
  # for unversioned objects when we have specified the :through options.
  def test_force_reload_through_normally
    actor = Actor.find 1
    first_use_case = actor.use_cases[0]
    second_use_case = actor.use_cases[0]
    assert_same first_use_case, second_use_case
    
    not_reloaded_use_case = actor.use_cases(false)[0]
    assert_same first_use_case, not_reloaded_use_case
    
    reloaded_use_case = actor.use_cases(true)[0]
    assert_not_same first_use_case, reloaded_use_case
    assert_not_same first_use_case, reloaded_use_case
    assert_equal first_use_case, reloaded_use_case
  end

  # If we go from a versioned object to a non-versioned object, we should just
  # get a normal object
  def test_follow_has_many_to_unsubversive_model
    project = Project.find_version(2, 3)
    assert_equal 2, project.current_users.length
    assert_equal 'Jimmy', project.current_users[0].name
    assert_equal 'Ole', project.current_users[1].name
  end

  def test_has_many_through
    actor = Actor.find_version(40, 1)
    assert_equal 0, actor.use_cases.size
    
    actor = Actor.find_version(40, 2)
    assert_equal 1, actor.use_cases.size
    assert_equal 'Use-case for has_many_through tests, number one', actor.use_cases[0].name
    
    actor = Actor.find_version(40, 3)
    assert_equal 2, actor.use_cases.size
    assert_equal 'Use-case for has_many_through tests, number one', actor.use_cases[0].name
    assert_equal 'Use-case for has_many_through tests, number two', actor.use_cases[1].name
    
    actor = Actor.find_version(40, 4)
    assert_equal 1, actor.use_cases.size
    assert_equal 'Use-case for has_many_through tests, number two', actor.use_cases[0].name
    
    actor = Actor.find_version(40, 5)
    assert_equal 0, actor.use_cases.size
  end
  
  # In ActiveRecord, if you follow a "has_many" and then follow back through a
  # belongs_to, you don't get the actual original object. This is the proof.
  def test_follow_has_many_and_back_normally
    project = Project.find 1
    assert_not_same project, project.actors[0].project
    assert_equal project.id, project.actors[0].project.id
  end
  
  # According to the previous test, going through a "has_many" and back should
  # not give the same object.
  def test_follow_has_many_and_back
    project = Project.find_version(1, 2)
    assert_not_same project, project.actors[0].project
    assert_equal project.id, project.actors[0].project.id
    assert_equal project.version, project.actors[0].project.version
  end
end
