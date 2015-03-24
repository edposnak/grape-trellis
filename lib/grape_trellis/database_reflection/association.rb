module Grape
  module Trellis
    module DatabaseReflection
      class Association
        ATTRIBUTES = [:child_table, :foreign_key, :parent_table, :primary_key]
        attr_reader *ATTRIBUTES

        abstract_method :type, :associated_table

        def initialize(foreign_key_or_other_association)
          @child_table  = foreign_key_or_other_association.child_table.to_s.freeze
          @foreign_key  = foreign_key_or_other_association.foreign_key.to_s.freeze
          @parent_table = foreign_key_or_other_association.parent_table.to_s.freeze
          @primary_key  = foreign_key_or_other_association.primary_key.to_s.freeze
        end

        def is_direct?
          true
        end

        def is_joined?
          !is_direct?
        end

        def conventional_foreign_key?
          parent_table == ForeignKeyNamingConvention.parent_table_for(foreign_key)
        end

        def conventional_primary_key?
          primary_key == ForeignKeyNamingConvention::PRIMARY_KEY
        end

        # Returns true if this association has a conventional foreign key pointing to the given table_name
        def conventional_parent?(table_name)
          parent_table == table_name && conventional_foreign_key?
        end


        def singular_association_name
          ForeignKeyNamingConvention.singular_association_name(foreign_key)
        end

        def plural_association_name
          ForeignKeyNamingConvention.plural_association_name(foreign_key)
        end

        def named?(ass_name)
          name == ass_name.to_s
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
      end
    end
  end
end