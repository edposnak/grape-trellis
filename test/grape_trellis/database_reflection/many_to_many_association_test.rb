require_relative '../../test_helper'

module Grape::Trellis
  module DatabaseReflection
    class TestManyToManyAssociation < Minitest::Test

      # TODO DRY these helpers with other tests, move to test_helper.rb
      def many_to_one_ass(rel, foreign_key, foreign_table, primary_key=:id)
        DatabaseReflection::ManyToOneAssociation.new DatabaseReflection::ForeignKeyFinder::ForeignKeyInfo.new(rel, foreign_key, foreign_table, primary_key)
      end

      def many_to_many_ass(ass_to_me, ass_to_other)
        DatabaseReflection::ManyToManyAssociation.new ass_to_me, ass_to_other
      end

      ##############################################################################################################
      # describe #disambiguate_name!

      def test_disambiguate_name_with_unconventional_join_table
        join = many_to_many_ass many_to_one_ass(:unconventional_groups_users, :user_id, :users, :id),
                                many_to_one_ass(:unconventional_groups_users, :groups_id, :groups, :id)
        join.disambiguate_name!
        assert_equal 'unconventional_groups_users_groups', join.name
      end

      def test_disambiguate_name_with_conventional_join_table
        join = many_to_many_ass many_to_one_ass(:user_groups, :user_id, :users, :id),
                                many_to_one_ass(:user_groups, :groups_id, :groups, :id)
        join.disambiguate_name!
        assert_equal 'groups', join.name
      end

      def test_disambiguate_name_with_conventional_join_table_backwards
        join = many_to_many_ass many_to_one_ass(:user_groups, :groups_id, :groups, :id),
                                many_to_one_ass(:user_groups, :user_id, :users, :id)
        join.disambiguate_name!
        assert_equal 'users', join.name
      end

    end
  end
end

