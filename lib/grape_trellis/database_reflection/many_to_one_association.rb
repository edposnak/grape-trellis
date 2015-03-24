module Grape
  module Trellis
    module DatabaseReflection
      class ManyToOneAssociation < Association

        def type
          :many_to_one
        end

        def associated_table
          parent_table
        end

        # Returns the name of a referenced association according to the naming convention
        #
        # @return [String] the name of the referenced association
        #
        def name
          singular_association_name
        end

      end
    end
  end
end
