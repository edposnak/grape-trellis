require_relative '../../../test_helper'

module Grape::Trellis
  module Generators
    module Sequel

      class TestModelCodeGenerator < Minitest::Test

        def setup
          @generator = ModelCodeGenerator.new(Mart::Relation.new(:test_table, []))
        end

        ##############################################################################################################
        # describe #code_for_association

        def code_for_association(ass)
          @generator.code_for_association(ass)
        end

        def many_to_one_ass(rel, foreign_key, foreign_table, primary_key=:id)
          Mart::ManyToOneAssociation.construct(rel, foreign_key, foreign_table, primary_key)
        end

        def one_to_many_ass(rel, foreign_key, foreign_table, primary_key=:id)
          Mart::OneToManyAssociation.construct(rel, foreign_key, foreign_table, primary_key)
        end


        def test_many_to_one_with_conventional_key
          assert_equal 'many_to_one :group',
                       code_for_association(many_to_one_ass(:users, :group_id, :groups))
        end

        def test_many_to_one_with_unconventional_key
          assert_equal 'many_to_one :tribe, class: :Group, key: :tribe',
                       code_for_association(many_to_one_ass(:users, :tribe, :groups))
        end

        def test_many_to_one_with_foreign_key_that_looks_like_a_conventional_key
          assert_equal 'many_to_one :football_team, class: :Group, key: :football_team_id',
                       code_for_association(many_to_one_ass(:users, :football_team_id, :groups))
        end

        def test_one_to_many_with_unconventional_key
          assert_equal 'one_to_many :tribe_users, class: :User, key: :tribe',
                       code_for_association(one_to_many_ass(:users, :tribe, :groups))
        end

        def test_one_to_many_with_unconventional_key_created_by
          assert_equal 'one_to_many :created_by_broadcasts, class: :Broadcast, key: :created_by',
                       code_for_association(one_to_many_ass(:broadcasts, :created_by, :users))
        end

        def test_one_to_many_with_foreign_key_that_looks_like_a_conventional_key
          assert_equal 'one_to_many :billing_manager_billing_accounts, class: :BillingAccount, key: :billing_manager_id',
                       code_for_association(one_to_many_ass(:billing_accounts, :billing_manager_id, :users))
        end


        ##############################################################################################################
        # describe #code_for_join_association

        def code_for_join_association(join_ass)
          @generator.code_for_join_association(join_ass)
        end

        def test_many_to_many_with_conventional_keys
          skip 'pass me!'
        end

        def test_many_to_many_with_unconventional_key
          skip 'pass me!'
        end

      end

    end
  end
end


