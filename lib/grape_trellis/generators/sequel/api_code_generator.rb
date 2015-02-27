module Grape
  module Trellis
    module Generators
      module Sequel
        class APICodeGenerator < CodeGenerator

          def filename
            "#{resource.table_name.underscore}.rb"
          end


          def code
            methods = [:index, :show]
            (
            ['class API < Grape::API'] +
              ["  resource :#{resource.table_name} do"] +
              ['  end'] +
              ['end']
            ).join("\n")
          end

          def require_code
            "require 'api/#{filename}'"
          end

        end
      end
    end
  end
end