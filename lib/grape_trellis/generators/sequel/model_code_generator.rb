module Grape
  module Trellis
    module Generators
      module Sequel
        class ModelCodeGenerator < CodeGenerator

          def filename
            "#{model_class_name.underscore}.rb"
          end

          def code
            (
            ["class #{model_class_name} < Sequel::Model"] +
              resource.children.map { |c| "  one_to_many :#{c.table}" } +
              resource.parents.map { |p| "  many_to_one :#{p.table}" } +
              (options[:with_grape_entities] ? code_for_grape_entity : []) +
              ['end']
            ).join("\n")
          end

          def require_code
            "autoload #{model_class_name}, 'models/#{filename}'"
          end


          private

          def code_for_grape_entity
            [''] +
              ["  def entity ; Entity.new(self) ; end"] +
              ["  class Entity < Grape::Entity"] +
              ["    expose #{resource.columns.map { |cn| ":#{cn}" }.join(', ')}"] +
              resource.children.map { |c| "    # expose :#{c.table}, using: ::#{model_class_name(c)}::Entity" } +
              ['  end']
          end

          def model_class_name(model=nil)
            model ||= resource
            model.table_name.camelize.singularize
          end


        end
      end
    end
  end
end