module Grape
  module Trellis
    module Generators
      # Abstract Base class for all types of Generators
      class Generator
        abstract_method :generate
      end
    end
  end
end