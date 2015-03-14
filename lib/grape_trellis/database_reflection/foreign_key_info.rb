module Grape
  module Trellis
    module DatabaseReflection
      class ForeignKeyInfo
        extend ForeignKeyDiscovery

        # Holds information about a foreign key and provides helper methods for dealing with naming conventions

        ATTRIBUTES = [:constraint_name, :table, :column, :foreign_table, :foreign_column]
        attr_reader *ATTRIBUTES

        FOREIGN_KEY_REGEX = /_id$/ # by convention, foreign keys are named <foreign_table_singular>_id

        def initialize(*args)
          ATTRIBUTES.each {|a| instance_variable_set "@#{a}", args.shift }
          puts self if table.to_sym == :broadcasts
        end

        def eql?(other)
          ATTRIBUTES.all? { |f| send(f) == other.send(f) }
        end
        alias == eql?

        def hash
          ATTRIBUTES.map {|a| send(a)}.hash
        end

        def to_s
          "#{self.class} #{ATTRIBUTES.map {|a| "#{a}: #{send(a)}"}.join(', ')}"
        end

        def unconventional_key
          column if column != "#{foreign_table.singularize}_id"
        end

        def unconventional_primary_key
          foreign_column if foreign_column != 'id'
        end

        module ClassMethods
          # Constructs a ForeignKey from the given attrs
          # @param [Hash] attrs contains the foreign_key, foreign_table, and foreign_column
          # @return [ForeignKeyInfo]
          #
          def for(attrs)
            ForeignKeyInfo.new *(ATTRIBUTES.map { |a| attrs[a] })
          end

          ##############################################################################################################
          # TODO move to naming_conventions

          # Returns the name of a referenced table if the given column_name follows the naming
          # convention, otherwise returns nil
          #
          # Example: referenced_table_by_convention('group_id') => 'groups'
          #
          # @param [String|Symbol] column_name the name of the referencing column
          # @return [String|NilClass] the name of the referenced table if found by convention
          #
          def referenced_table_by_convention(column_name)
            column_name =~ FOREIGN_KEY_REGEX && referenced_table(column_name)
          end

          # Returns the name of a referenced association if the given column_name follows the naming
          # convention, otherwise returns nil
          #
          # Example: association_by_convention('group_id') => 'group'
          #
          # @param [String|Symbol] column_name the name of the referencing column
          # @return [String|NilClass] the name of the referenced association if found by convention
          #
          def association_by_convention(column_name)
            column_name =~ FOREIGN_KEY_REGEX && referenced_association(column_name)
          end

          private

          def referenced_table(column_name)
            referenced_association(column_name).pluralize.freeze
          end

          def referenced_association(column_name)
            fk_col = column_name.to_s
            fk_col[0...fk_col.index(FOREIGN_KEY_REGEX)].freeze
          end

        end
        extend ClassMethods

      end

    end
  end
end