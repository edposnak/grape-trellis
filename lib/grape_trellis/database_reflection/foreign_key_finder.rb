module Grape
  module Trellis
    module DatabaseReflection
      class ForeignKeyFinder
        ForeignKeyInfo = Struct.new :child_table, :foreign_key, :parent_table, :primary_key

        module FinderMethods

          # Returns the set of foreign key constraints on the given table residing in the given db
          # @param [Relation] relation the relation to search for constraints
          # @param [Sequel::Postgres::Database] db the database in which to look
          # @return [Array<ForeignKeyInfo>] info for foreign keys in the given table and db
          #
          def find_by_constraints(relation, db)
            db[constraint_query(relation.table_name.to_sym)].all.map do |attrs|
              ForeignKeyInfo.new(attrs[:child_table], attrs[:foreign_key],
                                 attrs[:parent_table], attrs[:primary_key])
            end
          end

          # Returns a set of possible foreign keys based on columns in this relation matching the naming convention and
          # reference a table name that is in the given schema
          #
          # @param [Relation] relation the relation to search
          # @param [Schema] schema defines the set of referenceable tables
          #
          def find_by_naming_conventions(relation, schema)
            relation.column_names.map do |possible_foreign_key|
              if parent_table = ForeignKeyNamingConvention.parent_table_for(possible_foreign_key)
                if schema.has_table?(parent_table)
                  ForeignKeyInfo.new(relation.table_name, possible_foreign_key,
                                     parent_table, ForeignKeyNamingConvention::PRIMARY_KEY)
                end
              end
            end.compact
          end


          private

          def constraint_query(table)
            # TODO incorporate namespaces

            <<-CONSTRAINT_QUERY_SQL
              SELECT pg_constraint.conname AS constraint_name,
                     pg_class_con.relname AS child_table,
                     pg_attribute_con.attname AS foreign_key,
                     pg_class_ref.relname AS parent_table,
                     pg_attribute_ref.attname AS primary_key

              FROM pg_constraint,
                   pg_class pg_class_con,
                   pg_class pg_class_ref,
                   pg_attribute
                   pg_attribute_con,
                   pg_attribute pg_attribute_ref

              WHERE pg_class_con.relname = '#{table}' AND pg_constraint.contype = 'f' AND
                    pg_constraint.conrelid = pg_class_con.oid AND pg_attribute_con.attrelid = pg_constraint.conrelid AND pg_attribute_con.attnum = ANY (pg_constraint.conkey) AND
                    pg_constraint.confrelid = pg_class_ref.oid AND pg_attribute_ref.attrelid = pg_constraint.confrelid AND pg_attribute_ref.attnum = ANY (pg_constraint.confkey)

            CONSTRAINT_QUERY_SQL
          end
        end
        extend FinderMethods

      end
    end
  end
end
