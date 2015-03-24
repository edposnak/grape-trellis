module Grape
  module Trellis
    module DatabaseReflection
      module ForeignKeyNamingConvention
        PRIMARY_KEY       = 'id' # by convention, primary keys are named id
        FOREIGN_KEY_REGEX = /_id$/ # by convention, foreign keys are named <parent_table_singular>_id

        module_function

        # Returns the name of a possibly referenced table if the given possible_foreign_key follows the naming convention,
        # otherwise returns nil
        #
        # Example: parent_table_for('group_id') => 'groups'
        #
        # @param [String|Symbol] possible_foreign_key name of the possibly referencing column
        # @return [String|NilClass] name of the possibly referenced table if found by convention
        #
        def parent_table_for(possible_foreign_key)
          possible_foreign_key = possible_foreign_key.to_s
          possible_foreign_key =~ FOREIGN_KEY_REGEX && singular_association_name(possible_foreign_key).pluralize.freeze
        end

        # Returns a many_to_one association name based on the given foreign_key according to the naming convention
        # Examples:
        #   to_association('group_id') => 'group'
        #   to_association('team_id') => 'team'
        #   to_association('created_by') => 'created_by'
        #
        def singular_association_name(foreign_key)
          if foreign_key =~ FOREIGN_KEY_REGEX
            foreign_key[0...foreign_key.index(FOREIGN_KEY_REGEX)]
          else
            foreign_key
          end
        end

        # Returns a one_to_many association name based on the given foreign_key according to the naming convention
        # Examples:
        #   to_association('group_id') => 'groups'
        #   to_association('team_id') => 'teams'
        #   to_association('created_by') => 'created_bies'
        #
        def plural_association_name(foreign_key)
          singular_association_name(foreign_key).pluralize
        end

      end
    end
  end
end
