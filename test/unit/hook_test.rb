require File.dirname(__FILE__) + '/../test_helper'

class HookTest < Test::Unit::TestCase
  def setup
    # I'd like to get rid of this code, but how?!?
    UseCase.find(:all).each { |use_case| use_case.destroy }
    UseCaseVersion.find(:all).each { |use_case_version| use_case_version.destroy }
    VersionNumber.find(:all).each { |version_number| version_number.destroy }
  end
  
  def test_creation
    new_use_case = UseCase.create(:project_id => 1, :name => 'A newly created use-case')

    assert_equal 1, UseCaseVersion.find(:all).length
    assert_equal 1, UseCase.find(:all).length
    assert_equal 1, VersionNumber.find(:all).length
    
    version_number = VersionNumber.find(:first)
    assert 10 > (Time.new - version_number.created_at)

    use_case_version = UseCaseVersion.find(:first)
    assert_equal 1, use_case_version.project_id
    assert_equal 'A newly created use-case', use_case_version.name
    assert !use_case_version.deleted
    assert_equal new_use_case.id, use_case_version.original_id
    assert_equal version_number.id, use_case_version.version
  end
  
  def test_update
    new_use_case = UseCase.create(:project_id => 1, :name => 'A newly created use-case')
    new_use_case.name = 'An updated use-case'
    new_use_case.save!

    assert_equal 2, UseCaseVersion.find(:all).length
    assert_equal 1, UseCase.find(:all).length
    assert_equal 2, VersionNumber.find(:all).length

    version_numbers = VersionNumber.find(:all, :order => 'id')
    assert 10 > (Time.new - version_numbers[0].created_at)
    assert 10 > (Time.new - version_numbers[1].created_at)

    use_case_versions = UseCaseVersion.find_all_by_original_id(new_use_case.id, :order => 'id')
    assert_equal 2, use_case_versions.length

    assert_equal version_numbers[0].id, use_case_versions[0].version

    assert_equal 1, use_case_versions[1].project_id
    assert_equal 'An updated use-case', use_case_versions[1].name
    assert !use_case_versions[1].deleted
    assert_equal new_use_case.id, use_case_versions[1].original_id
    assert_equal version_numbers[1].id, use_case_versions[1].version
  end
  
  def test_delete
    new_use_case = UseCase.create(:project_id => 1, :name => 'A newly created use-case')
    new_use_case.destroy

    assert_equal 2, UseCaseVersion.find(:all).length
    assert_equal 0, UseCase.find(:all).length
    assert_equal 2, VersionNumber.find(:all).length

    version_numbers = VersionNumber.find(:all, :order => 'id')
    assert 10 > (Time.new - version_numbers[0].created_at)
    assert 10 > (Time.new - version_numbers[1].created_at)
   
    use_case_versions = UseCaseVersion.find_all_by_original_id(new_use_case.id)
    assert_equal 2, use_case_versions.length

    assert_equal version_numbers[0].id, use_case_versions[0].version

    assert use_case_versions[1].deleted
    assert_equal new_use_case.id, use_case_versions[1].original_id
    assert_equal version_numbers[1].id, use_case_versions[1].version
  end
  
  def test_versioned_objects_must_not_be_updated
    new_use_case = UseCase.create(:project_id => 1, :name => 'A new use-case')
    use_case = UseCase.find_version(new_use_case.id, VersionNumber.current_version)
    use_case.name = 'My project'
    assert_raise(Exception) { use_case.save! }
  end

  def test_unversioned_objects_can_be_updated
    new_use_case = UseCase.create(:project_id => 1, :name => 'A new use-case')
    use_case = UseCase.find new_use_case.id
    use_case.name = 'My project'
    assert_nothing_raised { use_case.save! }
  end

  def test_versioned_objects_must_not_be_destroyed
    new_use_case = UseCase.create(:project_id => 1, :name => 'A new use-case')
    use_case = UseCase.find_version(new_use_case.id, VersionNumber.current_version)
    assert_raise(Exception) { use_case.destroy }
  end

  def test_unversioned_objects_can_be_destroyed
    new_use_case = UseCase.create(:project_id => 1, :name => 'A new use-case')
    use_case = UseCase.find new_use_case.id
    assert_nothing_raised { use_case.destroy }
  end
end