require File.dirname(__FILE__) + '/helpers/test_setup'

class VersionNumberTest < Test::Unit::TestCase
  def setup
    setup_db
  end

  def teardown
    teardown_db
  end
  
  def test_current_version
    assert_equal 0, VersionNumber.current_version
    
    vn = VersionNumber.create
    assert_equal vn.id, VersionNumber.current_version
    
    vn = VersionNumber.create
    assert_equal vn.id, VersionNumber.current_version
  end
end
