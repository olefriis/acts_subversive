require "#{File.dirname(__FILE__)}/test_setup"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

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
