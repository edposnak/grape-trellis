module Grape
  module Trellis
    module DatabaseReflection

      class Relation
        attr_reader :table_name, :column_names

        attr_reader :associations, :joins
        private :associations, :joins

        def initialize(table, columns)
          @table_name   = table.to_s.freeze
          @column_names = columns.map(&:to_s).map(&:freeze)
          @associations = []
          @joins = []
        end

        # Returns the association on this relation with the given name or nil if none exists
        # @return [Association]
        def association_named(ass_name)
          (associations + joins).detect {|ass| ass.named?(ass_name)}
        end

        def column_named(col_name)
          canon_col_name = col_name.to_s
          column_names.detect {|col| col == canon_col_name}
        end

        ############################################################################
        def direct_associations
          associations
        end

        def join_associations
          joins
        end

        def associate_many_to_one(foreign_key)
          associations << ManyToOneAssociation.new(foreign_key)
        end

        def associate_one_to_many(foreign_key)
          associations << OneToManyAssociation.new(foreign_key)
        end

        # @param [ManyToOneAssociation] ass_to_me
        # @param [ManyToOneAssociation] ass_to_other
        def associate_many_to_many(ass_to_me, ass_to_other)
          joins << ManyToManyAssociation.new(ass_to_me, ass_to_other)
        end

        # Returns pairs of many_to_one associations that could make up a join through this relation
        # @return [Array<[String,String]]
        def possible_join_pairs
          parent_associations.combination(2).to_a
        end

        # Finds joins with the same name and marks all but the conventional one as requiring a long name.
        #
        def disambiguate_conflicting_join_names!
          # Corner case problem: if the schema changes and a conventional join table is added, then what was formerly
          # foo many_to_many: :bars  join_table: poop_stinks, will need to be (manually) changed to something like
          # foo many_to_many: :poop_stink_bars, class: :Bar,  join_table: poop_stinks
          # and a request for foo.bars will now return bars from the foo_bars join table instead of the poop_stinks join
          # table. Making all non-conventional joins have long names is worse since in most cases (80/20) the "real"
          # join is just the existing unconventionally named table.
          # many_to_many :bars seems better for a vast majority of joins that are not conventional.

          joins.group_by(&:name).values.select { |v| v.count > 1 }.each do |dup_joins|
            dup_joins.each { |join| join.disambiguate_name! }
          end
        end

        def parent_associations
          associations.select { |a| a.is_a?(ManyToOneAssociation) }
        end

        def child_associations
          associations.select { |a| a.is_a?(OneToManyAssociation) }
        end

        # Returns true if this relation has a many_to_one association with the given table_name
        # @param [String] table_name
        def has_direct_conventional_parent?(table_name)
          parent_associations.any? {|a| a.conventional_parent?(table_name) }
        end

        def to_s
          table_name
        end
      end
    end
  end
end