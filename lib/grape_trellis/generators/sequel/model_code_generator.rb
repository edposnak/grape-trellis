module Grape
  module Trellis
    module Generators
      module Sequel
        class ModelCodeGenerator < CodeGenerator

          def filename
            "#{model_class_name.underscore}.rb"
          end

          def require_preamble
            nil
          end

          def code
            (
            ["class #{model_class_name} < Sequel::Model"] +
              resource.direct_associations.sort_by(&:name).map { |ass| "  #{code_for_association(ass)}" } +
              resource.join_associations.sort_by(&:name).map { |ass| "  #{code_for_join_association(ass)}" } +
              (options[:with_grape_entities] ? code_for_grape_entity : []) +
              ['end']
            ).join("\n")
          end

          def code_for_association(ass)
            r = "#{ass.type} :#{ass.name}"
            r << ", class: :#{model_class_name(ass.associated_table)}, key: :#{ass.foreign_key}" unless ass.conventional_foreign_key?
            # primary_key always defaults to the primary key of the referenced table
            r
          end

          # Example:
          #   many_to_many :badges, left_key: :user_id, right_key: :badge_id, join_table: :badge_users
          #
          def code_for_join_association(join_ass)
            ass_to_me, ass_to_other = join_ass.direct_associations

            r = "#{join_ass.type} :#{join_ass.name}"
            r << ", class: :#{model_class_name(join_ass.associated_table)}" unless join_ass.name == join_ass.associated_table
            r << ", right_key: :#{ass_to_other.foreign_key}" unless join_ass.name == join_ass.associated_table && ass_to_other.conventional_foreign_key?
            r << ", left_key: :#{ass_to_me.foreign_key}" unless ass_to_me.conventional_foreign_key?
            r << ", join_table: :#{join_ass.child_table}"
            # primary_key always defaults to the primary key of the referenced table
            r
          end

          def require_code
            ["require 'models/#{filename}'"]
          end


          private

          def code_for_grape_entity
            [''] +
              ["  def entity ; Entity.new(self) ; end"] +
              ["  class Entity < Grape::Entity"] +
              ["    expose #{resource.column_names.map { |cn| ":#{cn}" }.join(', ')}"] +
              resource.child_associations.map { |ass| "    # expose :#{ass.child_table}, using: ::#{model_class_name(ass.child_table)}::Entity" } +
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