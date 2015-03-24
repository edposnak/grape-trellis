module Grape
  module Trellis
    module DatabaseReflection
      class OneToManyAssociation < Association

        def type
          :one_to_many
        end

        def associated_table
          child_table
        end

        # Returns the name of a referenced association according to the naming convention
        #
        # @return [String] the name of the referenced association
        #
        def name
          conventional_foreign_key? ? child_table : "#{singular_association_name}_#{child_table}"
        end

      end
    end
  end
end
