module Grape
  module Trellis
    module Generators
      # Base class for all types of Resources
      class Resource
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

        def belongs_to(parent)
          parent.children << self
          self.parents << parent
        end

      end
    end
  end
end