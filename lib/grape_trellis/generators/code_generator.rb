module Grape
  module Trellis
    module Generators
      # Base class for all types of CodeGenerators
      class CodeGenerator
        abstract_method :filename, :code, :require_code

        attr_reader :resource, :options

        def initialize(resource, options={})
          @resource = resource
          @options  = options
        end

        private

        def model_class_name(table_name=nil)
          table_name ||= resource.table_name
          table_name.to_s.camelize.singularize
        end

      end
    end
  end
end