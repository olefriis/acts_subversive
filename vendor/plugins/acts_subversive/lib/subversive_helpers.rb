module ::ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Subversive
      def Subversive.copy_from_versioned(version_object, object, base_version) #:nodoc:
        for attribute in version_object.attributes
          object.send(attribute[0] + '=', attribute[1]) unless ['id', 'original_id', 'deleted'].include?(attribute[0])
        end
        object.id, object.base_version = version_object.attributes['original_id'], base_version
      end
      
      def Subversive.copy_to_versioned(version_object, object) #:nodoc:
        for attribute in object.attributes
          version_object.send(attribute[0] + '=', attribute[1]) unless ['id'].include?(attribute[0])
        end
        version_object.original_id = object.id
      end
      
      # Could be a lot nicer if we could just create a join condition and
      # let ActiveRecord do the surrounding "select * from #{table_name} v where ("
      # and "LIMIT 1", but instead it creates this SQL:
      #
      # select #{table_name}.* from #{table_name} v where (
      #
      # and SQLite doesn't understand that (says that there's no #{table_name}
      # table).
      def Subversive.condition_find_versioned(table_name, id, version, id_column='original_id') #:nodoc:
        s = <<-END
          select * from #{table_name} v where (
            v.#{id_column} = ?
            and v.version = (
              select max(version)
              from #{table_name} v2
              where v.original_id = v2.original_id
                and v2.version <= ?)
            and v.deleted = ?)
          limit 1
        END
        [s, id, version, false]
      end

      def Subversive.find_version(klass, id, version)
        # Construct query
        version_table_name = klass.table_name.singularize + "_versions"
        cond = condition_find_versioned(version_table_name, id, version)

        # Find the versioned object
        version_class = eval(klass.name + 'Version')
        #object_version = version_class.find(first, :joins => 'v',
        #  :conditions => cond)
        objects_version = version_class.find_by_sql(cond)
        

        # Copy found versioned object to "normal" object
        object = nil
        if objects_version.size == 1
          object_version = objects_version[0]
          object = klass.new
          copy_from_versioned(object_version, object, version)
        end

        object
      end

      # Fetches all the objects of type class_name that have the column association_id_name set to
      # id, and fetches them in the version given.
      def Subversive.fetch_versioned_collection(class_name, association_id_name, id, version) #:nodoc:
        cond = condition_find_versioned(eval(class_name).table_name.singularize + '_versions',
          id, version, association_id_name)

        # De-reference the non-versioned class so it gets loaded
        eval(class_name)

        object_versions = eval(class_name + 'Version').find_by_sql(cond)
        versioned_objects = []
        for object_version in object_versions
          object = eval(class_name).new
          copy_from_versioned(object_version, object, version)
          versioned_objects << object
        end
        versioned_objects
      end
      
      # Finds the object that owns another object through "belongs_to".
      def Subversive.find_owning_object(owned, force_reload, owned_singular, owner_class_name,
        owned_version_plural, owner_versioned_class_name, foreign_key)
        return nil if owned.attributes[foreign_key].nil?

        instance_variable_name = '@' + owned_singular
        if (force_reload || !owned.instance_variable_get(instance_variable_name))
          other_class = eval(owner_class_name)
          if (other_class.versioned_class?)
            other_versioned_class = eval(owner_versioned_class_name)
            base_version = owned.instance_variable_get('@base_version')
            cond = condition_find_versioned(owned_version_plural,
              owned.attributes[foreign_key], base_version)
            objects_version = other_versioned_class.find_by_sql(cond)
            if (objects_version.size == 1)
              object_version = objects_version[0]
              object = other_class.new
              copy_from_versioned(object_version, object, base_version)
            else
              object = nil
            end
          else
            object = other_class.find(owned.attributes[foreign_key])
          end
          owned.instance_variable_set(instance_variable_name, object)
        end
        owned.instance_variable_get(instance_variable_name)
      end
      
      def Subversive.find_owned_objects_through(owner, force_reload, owner_class_name, owned_name_plural, through_name_plural)
        instance_variable_name = '@' + owned_name_plural
        if (force_reload || !owner.instance_variable_get(instance_variable_name))
          path_class_name = through_name_plural.singularize.camelize
          path_objects = fetch_versioned_collection(path_class_name,
            owner_class_name + '_id', owner.id, owner.base_version)

          objects = []
          for path_object in path_objects
            object = path_object.send(owned_name_plural.singularize)
            objects << object if object
          end
          owner.instance_variable_set(instance_variable_name, objects)
        end
        owner.instance_variable_get(instance_variable_name)
      end
      
      def Subversive.find_owned_objects(owner, force_reload, owned_class, owned_class_plural, foreign_key)
        instance_variable_name = '@' + owned_class_plural
        if (force_reload || !owner.instance_variable_get(instance_variable_name))
          owner.instance_variable_set(instance_variable_name,
            owned_class.versioned_class? ?
              fetch_versioned_collection(owned_class.name, foreign_key, owner.id, owner.base_version) :
              owned_class.find(:all, :conditions => [foreign_key + ' = ?', owner.id]))
        end
        owner.instance_variable_get(instance_variable_name)
      end
    end
  end
end
