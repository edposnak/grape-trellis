require_relative '../../../test_helper'

require 'dart/database'
require 'dart/database/test_helpers'

module Grape::Trellis
  module Generators
    module Sequel

      class TestModelCodeGenerator < Minitest::Test
        include Dart::Database::TestHelpers

        def setup
          @generator = ModelCodeGenerator.new(relation(:test_table, []))
        end

        ##############################################################################################################
        # describe #code_for_association

        def code_for_association(ass)
          @generator.code_for_association(ass)
        end

        def test_many_to_one_with_conventional_key
          assert_equal 'many_to_one :group',
                       code_for_association(many_to_one_ass(:users, :group_id, :groups, :id))
        end

        def test_many_to_one_with_unconventional_key
          assert_equal 'many_to_one :tribe, class: :Group, key: :tribe',
                       code_for_association(many_to_one_ass(:users, :tribe, :groups, :id))
        end

        def test_many_to_one_with_foreign_key_that_looks_like_a_conventional_key
          assert_equal 'many_to_one :football_team, class: :Group, key: :football_team_id',
                       code_for_association(many_to_one_ass(:users, :football_team_id, :groups, :id))
        end

        def test_one_to_many_with_unconventional_key
          assert_equal 'one_to_many :tribe_users, class: :User, key: :tribe',
                       code_for_association(one_to_many_ass(:users, :tribe, :groups, :id))
        end

        def test_one_to_many_with_unconventional_key_created_by
          assert_equal 'one_to_many :created_by_broadcasts, class: :Broadcast, key: :created_by',
                       code_for_association(one_to_many_ass(:broadcasts, :created_by, :users, :id))
        end

        def test_one_to_many_with_foreign_key_that_looks_like_a_conventional_key
          assert_equal 'one_to_many :billing_manager_billing_accounts, class: :BillingAccount, key: :billing_manager_id',
                       code_for_association(one_to_many_ass(:billing_accounts, :billing_manager_id, :users, :id))
        end


        ##############################################################################################################
        # describe #code_for_join_association

        def code_for_join_association(join_ass)
          @generator.code_for_join_association(join_ass)
        end

        def test_many_to_many_with_conventional_keys
          left_ass = many_to_one_ass(:groups_users, :user_id, :users, :id)
          right_ass = many_to_one_ass(:groups_users, :group_id, :groups, :id)
          assert_equal "many_to_many :groups, join_table: :groups_users",
                       code_for_join_association(many_to_many_ass(left_ass, right_ass))
        end

        def test_many_to_many_with_unconventional_left_key
          left_ass = many_to_one_ass(:groups_users, :member_id, :users, :id)
          right_ass = many_to_one_ass(:groups_users, :group_id, :groups, :id)
          assert_equal "many_to_many :groups, left_key: :member_id, join_table: :groups_users",
                       code_for_join_association(many_to_many_ass(left_ass, right_ass))
        end

        def test_many_to_many_with_unconventional_right_key
          left_ass = many_to_one_ass(:groups_users, :user_id, :users, :id)
          right_ass = many_to_one_ass(:groups_users, :team_id, :groups, :id)
          assert_equal "many_to_many :teams, class: :Group, right_key: :team_id, join_table: :groups_users",
                       code_for_join_association(many_to_many_ass(left_ass, right_ass))
        end

        def test_many_to_many_with_unconventional_left_and_right_key
          left_ass = many_to_one_ass(:groups_users, :member_id, :users, :id)
          right_ass = many_to_one_ass(:groups_users, :team_id, :groups, :id)
          assert_equal "many_to_many :teams, class: :Group, right_key: :team_id, left_key: :member_id, join_table: :groups_users",
                       code_for_join_association(many_to_many_ass(left_ass, right_ass))
        end

      end

    end
  end
end


