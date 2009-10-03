class ActiveRecord::Base #:nodoc:
  # The "world version" that this instance is in
  def base_version=(bv)
    @base_version = bv
  end
  
  # True if this instance has been retrieved from a versioned search
  def versioned?
    @base_version != nil
  end
  
  # Indicates whether or not this class is versioned.
  def self.versioned_class?
    # Versioned classes will override this method with another
    # method that will return true
    false
  end
end

ActiveRecord::Base.extend(ActiveRecord::Acts::Subversive)
