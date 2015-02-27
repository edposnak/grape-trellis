module Grape
  module Trellis
    module Generators
      # Base class for all types of Resources
      class Generator
        abstract_method :generate
      end
    end
  end
end