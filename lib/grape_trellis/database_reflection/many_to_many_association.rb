module Grape
  module Trellis
    module DatabaseReflection
      class ManyToManyAssociation < Association

        attr_reader :ass_to_me, :ass_to_other
        private :ass_to_me, :ass_to_other

        # for an m2m association on users we'd pass in:
        #   ass_to_me:    badge_users.user_id -> users.id
        #   ass_to_other: badge_users.badge_id -> badges.id
        # =>
        #   many_to_many :badges, join_table: :badge_users

        def initialize(ass_to_me, ass_to_other)
          @ass_to_me, @ass_to_other = ass_to_me, ass_to_other
          super(ass_to_other)
        end

        # Returns a pair of direct associations from the join table to the respective associated tables
        def direct_associations
          [ass_to_me, ass_to_other]
        end

        def type
          :many_to_many
        end

        def associated_table
          # returns ass_to_other.parent_table
          parent_table
        end

        def is_direct?
          false
        end

        # Returns the name of a referenced association according to the naming convention
        #
        # @return [String] the name of the referenced association
        #
        def name
          r = plural_association_name # will be groups if ass_to_other.foreign_key is group_id
          if @disambiguate_name
            # add a foreign_key disambiguator when the key referencing me is unconventional
            fk_part = "_#{ass_to_me.foreign_key}" unless ass_to_me.conventional_foreign_key?
            r = "#{child_table.singularize}#{fk_part}_#{r}"
          end
          r
        end

        # forces long-form name to disambiguate from other joins to same association, where short-form name is the same
        def disambiguate_name!
          return if is_semi_conventional_join_table?
          @disambiguate_name = true
        end

        private

        # Returns true if the table joining t1 and t2 is semi-conventional, i.e. some variation of t1_t2 or t2_t1, for
        # plural or singular forms of t1 and t2
        def is_semi_conventional_join_table?
          @semi_conventional_join_table ||= begin
            me_names = [ass_to_me.parent_table, ass_to_me.parent_table.singularize].uniq
            other_names = [ass_to_other.parent_table, ass_to_other.parent_table.singularize].uniq
            name_combos = (me_names.product(other_names) + other_names.product(me_names)).map { |t1, t2| "#{t1}_#{t2}" }
            name_combos.include?(child_table)
          end
        end

      end
    end
  end
end
