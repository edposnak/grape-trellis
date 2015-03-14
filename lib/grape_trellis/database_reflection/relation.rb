module Grape
  module Trellis
    module DatabaseReflection

      class Relation
        attr_reader :table, :columns
        attr_reader :children, :parents

        def initialize(table, columns)
          @table, @columns    = table, columns
          @children, @parents = [], []
        end

        def table_name
          table.to_s
        end

        def column_names
          columns.map(&:to_s)
        end

        def many_to_one(foreign_key)
          self.parents << foreign_key
        end

        def one_to_many(foreign_key)
          self.children << foreign_key
        end

        def many_to_many(other_relation, foreign_key)

        end



      end
    end
  end
end