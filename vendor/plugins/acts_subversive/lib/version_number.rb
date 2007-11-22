# An instance of the VersionNumber class is instantiated every time a subversive object is
# saved or deleted. The id fields of the VersionNumber objects are used as version numbers.
class ::VersionNumber < ActiveRecord::Base
  # The current version of the database. This corresponds to the id value for the newest VersionNumber object.
  def self.current_version
    version_number = VersionNumber.find(:first, :conditions => 'id = (select max(id) from version_numbers)')
    version_number ? version_number.id : 0
  end
end
