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
              resource.parents.map  { |fk| "  #{many_to_one(fk)}" } +
              (options[:with_grape_entities] ? code_for_grape_entity : []) +
              ['end']
            ).join("\n")
          end

          def many_to_one(fk)
            ass_name, class_name = if conventional_ass = ForeignKeyInfo.association_by_convention(fk.column)
                                     [conventional_ass, nil]
                                   else # e.g. broadcasts, created_by, users, id => many_to_one: :created_by, class: :User
                                     [fk.column, model_class_name(fk.foreign_table)]
            end

            "many_to_one :#{ass_name}#{class_name ? ":#{class_name}" : ''}#{unconventional_fk_spec(fk)}#{unconventional_pk_spec(fk)}"
          end

          def one_to_many(fk)
            "one_to_many :#{fk.table}#{unconventional_fk_spec(fk)}#{unconventional_pk_spec(fk)}"
          end

          def unconventional_fk_spec(fk)
            fk.unconventional_key ? ", key: #{fk.unconventional_key}" : ''
          end

          def unconventional_pk_spec(fk)
            fk.unconventional_primary_key ? ", primary_key: #{fk.unconventional_primary_key}" : ''
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