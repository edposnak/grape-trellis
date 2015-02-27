module Grape
  module Trellis
    module Generators
      # Base class for all types of Resources
      class CodeGenerator
        abstract_method :filename, :code, :require_code

        attr_reader :resource, :options

        def initialize(resource, options={})
          @resource = resource
          @options  = options
        end
      end
    end
  end
end