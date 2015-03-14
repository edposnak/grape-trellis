module Grape
  module Trellis
    module DatabaseReflection
      # Schema holds all the relations in a schema

      class Schema
        attr_reader :relation_map
        private :relation_map

        def initialize(db, db_tables=nil)
          # default to using all tables unless db_tables is passed in
          table_names = (db_tables || db.tables).map(&method(:canonical))
          @relation_map = Hash[table_names.map { |table| [table, Relation.new(table, db[table].columns)] }]
        end

        # Returns true if this schema has the given table
        # @param [Symbol|String] table
        def has_table?(table)
          tables.include? canonical(table)
        end

        # @return [Array<Symbol>] list of table names in this schema
        def tables
          relation_map.keys
        end

        # @return [Array<Relation>] list of +Relations+ in this schema
        def relations
          relation_map.values
        end

        # Returns a relation from this schema corresponding to the given table
        # @param [Symbol|String] table the name of the table
        # @return [Relation] the relation corresponding to the given table
        def relation(table)
          relation_map[canonical(table)]
        end
        alias [] relation

        private

        # maps the given table_name to canonical form required by Sequel
        def canonical(table)
          table.to_sym
        end

      end
    end
  end
end