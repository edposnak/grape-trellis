module Grape
  module Trellis
    module DatabaseReflection
      module ForeignKeyNamingConvention

        extend ActiveSupport::Concern

        FOREIGN_KEY_REGEX = /_id$/ # by convention, foreign keys are named <foreign_table_singular>_id

        # included do
        #   extend ClassMethods
        # end

        def unconventional_primary_key
          foreign_column if foreign_column != 'id'
        end

        # Returns the name of a referenced association if the foreign key column name references the foreign table
        # according to the naming convention, otherwise returns nil
        #
        # Examples:
        #   ForeignKeyInfo.new('users', 'group_id', 'groups', 'id').conventional_association => 'group'
        #   ForeignKeyInfo.new('users', 'team_id', 'groups', 'id').conventional_association => nil
        #
        # @param [String|Symbol] column_name the name of the referencing column
        # @return [String|NilClass] the name of the referenced association if found by convention
        #
        def conventional_association
          if foreign_table == self.class.referenced_table_by_convention(column)
            self.class.to_association(column)
          end
        end

        def unconventional_association
          self.class.to_association(column)
        end


        module ClassMethods
          # Returns the name of a possibly referenced table if the given column_name follows the naming convention,
          # otherwise returns nil
          #
          # Example: referenced_table_by_convention('group_id') => 'groups'
          #
          # @param [String|Symbol] column_name name of the possibly referencing column
          # @return [String|NilClass] name of the possibly referenced table if found by convention
          #
          def referenced_table_by_convention(column_name)
            column_name = column_name.to_s
            column_name =~ FOREIGN_KEY_REGEX && to_association(column_name).pluralize.freeze
          end

          # Returns the given column name as an association according to the naming convention
          # Examples:
          #   to_association('group_id') => 'group'
          #   to_association('team_id') => 'team'
          #   to_association('created_by') => 'created_by'
          #
          def to_association(column_name)
            column_name = column_name.to_s
            return column_name unless column_name =~ FOREIGN_KEY_REGEX
            column_name[0...column_name.index(FOREIGN_KEY_REGEX)]
          end

        end
      end
    end
  end
end
