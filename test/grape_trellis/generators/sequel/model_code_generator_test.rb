require_relative '../../../test_helper'

module Grape
  module Trellis
    module Generators
      module Sequel

        class TestModelCodeGenerator < Minitest::Test

          def setup
            @generator = ModelCodeGenerator.new(DatabaseReflection::Relation.new(:test_table, []))
          end

          FK = DatabaseReflection::ForeignKeyInfo

          def test_many_to_one_with_conventional_key
            fk = FK.new(nil, :users, :group_id, :groups, :id)
            assert_equal 'many_to_one :group', @generator.many_to_one(fk)
          end

          def test_many_to_one_with_unconventional_key
            fk = FK.new(nil, :users, :tribe, :groups, :id)
            assert_equal 'many_to_one :tribe, class: :Group, key: :tribe', @generator.many_to_one(fk)
          end

          def test_many_to_one_with_foreign_key_that_looks_like_a_conventional_key
            fk = FK.new(nil, :users, :football_team_id, :groups, :id)
            assert_equal 'many_to_one :football_team, class: :Group, key: :football_team_id', @generator.many_to_one(fk)
          end

          def test_one_to_many_with_unconventional_key
            fk = FK.new(nil, :users, :tribe, :groups, :id)
            assert_equal 'one_to_many :tribe_users, class: :User, key: :tribe', @generator.one_to_many(fk)
          end

          def test_one_to_many_with_unconventional_key_created_by
            fk = FK.new(nil, :broadcasts, :created_by, :users, :id)
            assert_equal 'one_to_many :created_by_broadcasts, class: :Broadcast, key: :created_by', @generator.one_to_many(fk)
          end

          def test_one_to_many_with_foreign_key_that_looks_like_a_conventional_key
            fk = FK.new(nil, :billing_accounts, :billing_manager_id, :users, :id)
            assert_equal 'one_to_many :billing_manager_billing_accounts, class: :BillingAccount, key: :billing_manager_id', @generator.one_to_many(fk)
          end
        end

      end
    end
  end
end


