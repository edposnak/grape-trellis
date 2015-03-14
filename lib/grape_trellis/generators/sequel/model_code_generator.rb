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
              resource.children.map { |fk| "  #{one_to_many(fk)}" } +
              resource.parents.map { |fk| "  #{many_to_one(fk)}" } +
              (options[:with_grape_entities] ? code_for_grape_entity : []) +
              ['end']
            ).join("\n")
          end

          def many_to_one(fk)
            assoc_spec = fk.conventional_association || "#{fk.unconventional_association}, class: :#{model_class_name(fk.foreign_table)}, key: :#{fk.column}"
            "many_to_one :#{assoc_spec}#{unconventional_pk_spec(fk)}"
          end

          def one_to_many(fk)
            assoc_spec = fk.conventional_association ? fk.table : "#{fk.unconventional_association}_#{fk.table}, class: :#{model_class_name(fk.table)}, key: :#{fk.column}"
            "one_to_many :#{assoc_spec}#{unconventional_pk_spec(fk)}"
          end

          def unconventional_pk_spec(fk)
            fk.unconventional_primary_key ? ", primary_key: :#{fk.unconventional_primary_key}" : ''
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
              resource.children.map { |fk| "    # expose :#{fk.table}, using: ::#{model_class_name(fk.table)}::Entity" } +
              ['  end']
          end

          def model_class_name(table_name=nil)
            table_name ||= resource.table_name
            table_name.to_s.camelize.singularize
          end

        end
      end
    end
  end
end