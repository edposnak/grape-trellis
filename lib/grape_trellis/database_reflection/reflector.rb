module Grape
  module Trellis
    module DatabaseReflection
      class Reflector

        attr_reader :db
        private :db

        attr_reader :exclude_tables_regex, :foreign_key_regex
        private :exclude_tables_regex, :foreign_key_regex

        # @param [String] database_url specifies database to reflect on
        #
        def initialize(database_url)
          @db = ::Sequel.connect(database_url)
        end


        # @param [Hash] options
        # @option options exclude_tables an Array or Regexp defining tables to exclude from the reflection
        # @option options naming_conventions identify associations according to rails naming conventions
        # @return [Array<Relation>]
        #
        def reflect_on_database(options={})
          find_foreign_keys_by_naming_conventions = options[:naming_conventions]
          exclude_tables = options[:exclude_tables]

          db_tables = db.tables
          db_tables.reject! { |t| exclude_tables.match(t) } if exclude_tables.is_a?(Regexp)
          db_tables -= exclude_tables.map(&:to_sym) if exclude_tables.is_a?(Enumerable)


          schema = Schema.new(db, db_tables)

          schema.relations.each do |relation|
            foreign_keys = ForeignKeyInfo.find_by_constraints(relation, db)
            foreign_keys |= ForeignKeyInfo.find_by_naming_conventions(relation, schema) if find_foreign_keys_by_naming_conventions

            foreign_keys.each do |foreign_key|
              if one_relation = schema.relation(foreign_key.foreign_table)
                relation.many_to_one(foreign_key)
                one_relation.one_to_many(foreign_key)
              else
                fail "schema does not contain a table named '#{foreign_key.foreign_table}'. Perhaps it was excluded accidentally?\nexclude_tables=#{exclude_tables}"
              end
            end

            # TODO many_to_many relations
          end

          schema.relations
        end
      end
    end
  end
end

