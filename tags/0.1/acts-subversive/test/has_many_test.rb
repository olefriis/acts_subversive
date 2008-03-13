require File.dirname(__FILE__) + '/helpers/test_setup'

class HasManyTest < Test::Unit::TestCase
  def setup
    setup_db
  end

  def teardown
    teardown_db
  end
  
  def test_has_many
    # Version 1, 2, and 3
    project = Project.create()
    actor1 = Actor.create(:project_id => project.id, :name => 'Actor in original version')
    actor2 = Actor.create(:project_id => project.id, :name => 'Other actor in original version')

    # Version 4
    actor2.name = 'Other actor in newer version'
    actor2.save!

    # Version 5
    actor1.name = 'Actor in newer version'
    actor1.save!

    # Version 6
    actor1.destroy


    # First version 3
    project = Project.find_version(1, 3)
    assert_equal 2, project.actors.size
    assert_equal 'Actor in original version', project.actors[0].name
    assert_equal 'Other actor in original version', project.actors[1].name

    # Version 4: One actor has changed name
    project = Project.find_version(1, 4)
    assert_equal 2, project.actors.size
    actors = project.actors.sort_by {|actor| actor.id}
    assert_equal 'Actor in original version', project.actors[0].name
    assert_equal 'Other actor in newer version', project.actors[1].name

    # Version 5: Another actor has changed name
    project = Project.find_version(1, 5)
    assert_equal 2, project.actors.size
    actors = project.actors.sort_by {|actor| actor.id}
    assert_equal 'Actor in newer version', actors[0].name
    assert_equal 'Other actor in newer version', actors[1].name

    # Version 6: An actor has been deleted
    project = Project.find_version(1, 6)
    assert_equal 1, project.actors.size
    assert_equal 'Other actor in newer version', project.actors[0].name
  end

  # The "force_reload" parameter must work
  def test_force_reload
    project = Project.create()
    Actor.create(:project_id => project.id)

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
    project = Project.create()
    Actor.create(:project_id => project.id)

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
    actor = Actor.create()
    use_case = UseCase.create()
    Act.create(:actor_id => actor.id, :use_case_id => use_case.id)

    actor = Actor.find_version(1, 3)
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
    actor = Actor.create()
    use_case = UseCase.create()
    Act.create(:actor_id => actor.id, :use_case_id => use_case.id)

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
    project = Project.create()
    User.create(:name => 'Jimmy', :current_project_id => project.id)
    User.create(:name => 'Ole', :current_project_id => project.id)

    project = Project.find_version(1, 3)
    assert_equal 2, project.current_users.length
    current_users = project.current_users.sort_by {|user| user.id}
    assert_equal 'Jimmy', current_users[0].name
    assert_equal 'Ole', current_users[1].name
  end

  def test_has_many_through
    # Version 1, 2, and 3
    actor = Actor.create()
    use_case_1 = UseCase.create(:name => 'Use-case for has_many_through tests, number one')
    use_case_2 = UseCase.create(:name => 'Use-case for has_many_through tests, number two')

    # Version 4
    act1 = Act.create(:actor_id => actor.id, :use_case_id => use_case_1.id)

    # Version 5
    act2 = Act.create(:actor_id => actor.id, :use_case_id => use_case_2.id)

    # Version 6
    act1.destroy

    # Version 7
    act2.destroy

    actor = Actor.find_version(1, 3)
    assert_equal 0, actor.use_cases.size
    
    actor = Actor.find_version(1, 4)
    assert_equal 1, actor.use_cases.size
    assert_equal 'Use-case for has_many_through tests, number one', actor.use_cases[0].name
    
    actor = Actor.find_version(1, 5)
    assert_equal 2, actor.use_cases.size
    assert_equal 'Use-case for has_many_through tests, number one', actor.use_cases[0].name
    assert_equal 'Use-case for has_many_through tests, number two', actor.use_cases[1].name
    
    actor = Actor.find_version(1, 6)
    assert_equal 1, actor.use_cases.size
    assert_equal 'Use-case for has_many_through tests, number two', actor.use_cases[0].name
    
    actor = Actor.find_version(1, 75)
    assert_equal 0, actor.use_cases.size
  end
  
  # In ActiveRecord, if you follow a "has_many" and then follow back through a
  # belongs_to, you don't get the actual original object. This is the proof.
  def test_follow_has_many_and_back_normally
    project = Project.create()
    Actor.create(:project_id => project.id)

    project = Project.find 1
    assert_not_same project, project.actors[0].project
    assert_equal project.id, project.actors[0].project.id
  end
  
  # According to the previous test, going through a "has_many" and back should
  # not give the same object.
  def test_follow_has_many_and_back
    project = Project.create()
    Actor.create(:project_id => project.id)

    project = Project.find_version(1, 2)
    assert_not_same project, project.actors[0].project
    assert_equal project.id, project.actors[0].project.id
    assert_equal project.version, project.actors[0].project.version
  end
end
