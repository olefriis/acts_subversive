require File.dirname(__FILE__) + '/../test_helper'

class VersionNumberTest < Test::Unit::TestCase
  fixtures :version_numbers

  def test_current_version
    assert_equal 0, VersionNumber.current_version
    
    vn = VersionNumber.create
    assert_equal vn.id, VersionNumber.current_version
    
    vn = VersionNumber.create
    assert_equal vn.id, VersionNumber.current_version
  end
end
