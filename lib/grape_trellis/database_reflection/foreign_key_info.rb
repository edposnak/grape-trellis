module Grape
  module Trellis
    module DatabaseReflection
      class ForeignKeyInfo
        include ForeignKeyNamingConvention
        extend ForeignKeyDiscovery

        # Holds information about a foreign key and provides helper methods for dealing with naming conventions

        ATTRIBUTES = [:constraint_name, :table, :column, :foreign_table, :foreign_column]
        attr_reader *ATTRIBUTES

        module ClassMethods
          # Constructs a ForeignKey from the given attrs
          # @param [Hash] attrs contains the foreign_key, foreign_table, and foreign_column
          # @return [ForeignKeyInfo]
          #
          def for(attrs)
            ForeignKeyInfo.new *(ATTRIBUTES.map { |a| attrs[a] })
          end
        end
        extend ClassMethods

        def initialize(*args)
          ATTRIBUTES.each {|a| instance_variable_set "@#{a}", args.shift.to_s }
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