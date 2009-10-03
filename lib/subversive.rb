require 'subversive_helpers'

module ::ActiveRecord #:nodoc:
  module Acts #:nodoc:
    # Included in ActiveRecord::Base when the acts_subversive plugin is
    # installed in a Rails application. To make use of the acts_subversive
    # plugin in a given class, simply add a line containing "acts_subversive" in
    # the class definition:
    #
    #  class Actor < ActiveRecord::Base
    #   acts_subversive
    #   
    #   belongs_to :project
    #   has_many :acts, :dependent => :destroy
    #   has_many :use_cases, :through => :acts
    #  end
    #
    # Then you will be able to find an object in a certain version, and your
    # normal associations will be able to handle versioning.
    module Subversive
      # Makes your model class versioned. The class gets the method find_version
      # to find a certain version of an object.
      #
      # When the acts_subversive plugin is installed, the ActiveRecord::Base
      # class is extended with the following methods:
      # * versioned? - To determine whether the receiver object has been found through a version search.
      # * versioned_class? - To determine whether the receiver class is versioned. 
      def acts_subversive
        class_eval do
          attr_accessor :version
          attr_accessor :base_version
        end
        
        version_class_name = name + 'Version'
        
        # Create XxxVersion class
        class_eval <<-END
          class ::#{version_class_name} < ActiveRecord::Base
          end
        END
        
        # Let the existing class know it's been versioned
        def self.versioned_class? #:nodoc:
          true
        end
        
        version_class = Class.const_get(version_class_name)
        
        # Create hooks for shadow-copying versions
        self.class_eval do
          before_save do |x|
            raise Exception, 'You cannot save a certain version of an object' if x.versioned?
          end
          before_destroy do |x|
            raise Exception, 'You cannot save a certain version of an object' if x.versioned?
          end
          
          after_save do |x|
            version_number = VersionNumber.create
            version_object = version_class.new
            ActiveRecord::Acts::Subversive::copy_to_versioned(version_object, x)
            version_object.version = version_number.id
            version_object.save!
          end
          after_destroy do |x|
            version_number = VersionNumber.create
            version_object = version_class.new
            version_object.original_id = x.id
            version_object.deleted = true
            version_object.version = version_number.id
            version_object.save!
          end

          def ==(o) #:nodoc:
            return false unless self.class == o.class
            return false unless self.versioned? == o.versioned?
            return super unless self.versioned?
            self.id == o.id
          end
        end
    
        # Finds the object with the given id in the given version.
        def self.find_version(id, version)
          ActiveRecord::Acts::Subversive::find_version(self, id, version)
        end
    
        # Redefine belongs_to and has_many
        class <<self
          alias subversive_has_many has_many
          alias subversive_belongs_to belongs_to
          alias subversive_has_and_belongs_to_many has_and_belongs_to_many
          alias subversive_has_one has_one
          
          # Redefinition of the normal belongs_to method. Works like the normal
          # belongs_to, but the generated association methods will handle
          # versioned associations.
          #
          # This method currently only alters the method with the given
          # association_id, even though it should throw exceptions if the user
          # tries to modify the association.
          #
          # Currently, the following options are supported:
          # * :class_name - The class at the other end of this association. (Default is association_id camelized.)
          # * :foreign_key - Foreign key used by the association. (Default is association_id with '_id' suffixed.)
          # 
          # Currently, the following options are not handled:
          # * :conditions
          # * :order
          # * :counter_cache (but makes no sense for versioned objects anyway)
          # * :include
          # * :polymorphic
          def belongs_to(association_id, options = {})
            subversive_belongs_to association_id, options

            singular = association_id.to_s
            other_class_name = options[:class_name] || singular.camelize
            version_plural = other_class_name.underscore + '_versions'
            other_versioned_class_name = other_class_name + 'Version'
            foreign_key = options[:foreign_key] || singular + '_id' 
            
            module_eval("alias subversive_#{singular} #{singular}")
      
            define_method(association_id) do |*args|
              if (versioned?)
                force_reload = args.first
                ActiveRecord::Acts::Subversive::find_owning_object(self,
                  force_reload, singular, other_class_name, version_plural,
                  other_versioned_class_name, foreign_key)
              else
                send("subversive_#{singular}", force_reload)
              end
            end
          end
          
          # Redefinition of the normal has_many method. Works like the normal
          # has_many, but the generated association methods will handle
          # versioned associations.
          #
          # This method currently only alters the method with the given
          # association_id, even though it should throw exceptions if the user
          # tries to modify the association.
          #
          # Currently, the following options are supported:
          # * :class_name - The class at the other end of this association. (Default is association_id singularized and camelized.)
          # * :foreign_key - Foreign key used by the association. (Default is association_id singularized with '_id' suffixed.)
          # * :through - Join model to perform the query through.
          # 
          # Currently, the following options are not handled:
          # * :conditions
          # * :order
          # * :group
          # * :dependent (but makes no sense for versioned objects anyway)
          # * :exclusively_dependent (but makes no sense for versioned objects anyway)
          # * :finder_sql
          # * :counter_sql
          # * :extend
          # * :include
          # * :limit
          # * :offset
          # * :select
          # * :as
          # * :source
          # * :source_type
          # * :uniq
          def has_many(association_id, options = {}, &extension)
            subversive_has_many association_id, options, &extension

            # Oi, a lot of variables we need
            this_class_name = class_name
            other_name_plural = association_id.to_s
            other_name_singular = other_name_plural.singularize
            other_class = eval(options[:class_name] || other_name_singular.camelize)
            foreign_key = options[:foreign_key] || this_class_name.underscore + '_id'
       
            module_eval("alias subversive_#{other_name_plural} #{other_name_plural}")
       
            if (options[:through])
              define_method_has_many_through(this_class_name, other_name_plural,
                options[:through].to_s)
            else
              define_method_has_many(other_class, other_name_plural, foreign_key)
            end
          end
          
          # Redefinition of the normal has_and_belongs_to_many association. Forwards to the normal
          # has_and_belongs_to_many, but logs a warning that acts_subversive does not support this
          # method.
          def has_and_belongs_to_many(association_id, options = {}, &extension)
            logger.warn "acts_subversive does not support has_and_belongs_to_many (used in #{class_name})"
            subversive_has_and_belongs_to_many association_id, options, &extension
          end
          
          def has_one(association_id, options = {})
            logger.warn "acts_subversive does not YET support has_one (used in #{class_name})"
            subversive_has_one association_id, options
          end

          # Defines the method to access an association through another class/table
          def define_method_has_many_through(this_class_name, final_name_plural, through_name_plural) #:nodoc:
            define_method(final_name_plural) do |*args|
              force_reload = args.first
              if (versioned?)
                ActiveRecord::Acts::Subversive::find_owned_objects_through(self,
                  force_reload, this_class_name, final_name_plural,
                  through_name_plural)
              else
                send("subversive_#{final_name_plural}", force_reload)
              end
            end
          end

          def define_method_has_many(final_class, final_name_plural, foreign_key) #:nodoc:
            define_method(final_name_plural) do |*args|
              force_reload = args.first
              if (versioned?)
                ActiveRecord::Acts::Subversive::find_owned_objects(self,
                  force_reload, final_class, final_name_plural, foreign_key)
              else
                send("subversive_#{final_name_plural}", force_reload)
              end
            end
          end
        end
      end
    end
  end
end
