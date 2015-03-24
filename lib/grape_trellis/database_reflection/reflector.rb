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
          exclude_tables = options.delete(:exclude_tables)
          db_tables = case exclude_tables
                      when Enumerable
                        db.tables - exclude_tables.map(&:to_sym)
                      when Regexp
                        db.tables.reject { |t| exclude_tables.match(t) }
                      else # don't exclude any tables
                        db.tables
                      end

          schema = get_schema(db_tables, options)
          schema.relations
        end

        # @param [Hash] options
        # @option options naming_conventions identify associations according to rails naming conventions
        #
        def get_schema(db_tables=nil, options={})
          schema = Schema.new(db, db_tables)

          schema.relations.each do |relation|
            # TODO consider finding just by one method or the other
            foreign_keys = ForeignKeyFinder.find_by_constraints(relation, db)
            foreign_keys |= ForeignKeyFinder.find_by_naming_conventions(relation, schema) if options[:naming_conventions]

            foreign_keys.each do |foreign_key|
              if one_relation = schema.relation(foreign_key.parent_table)
                relation.associate_many_to_one(foreign_key)
                one_relation.associate_one_to_many(foreign_key)
              else
                fail "schema does not contain a table named '#{foreign_key.parent_table}'. Perhaps it was excluded accidentally?"
              end
            end
          end

          # "pure" many_to_many relations in which the join table is named
          schema.relations.each do |relation|
            relation.possible_join_pairs.each do |ass1, ass2|
              r1, r2 = schema[ass1.parent_table], schema[ass2.parent_table]

              # skip if either relation already has a direct, conventional association to the other
              # e.g. don't users many_to_many groups if users has group_id
              # e.g do users many_to_many groups if users has reporting_group_id (many_to_one reporting_group, and many_to_many groups)
              next if r1.has_direct_conventional_parent?(r2.table_name) || r2.has_direct_conventional_parent?(r1.table_name)

              r1.associate_many_to_many(ass1, ass2)
              r2.associate_many_to_many(ass2, ass1)
            end
          end

          # By default joins are given short names. When multiple joins conflict on name, we ask the relation to
          # disambiguate them
          schema.relations.each(&:disambiguate_conflicting_join_names!)

          schema.relations.each do |relation|
            relation.send(:joins).group_by(&:name).select { |k, v| v.count > 1 }.each do |k, v|
              puts "AFTER DISAMBIGUATION #{relation} has #{v.count} m2m associations named #{k}" if v.count > 1
            end
          end
          schema
        end

      end
    end
  end
end

