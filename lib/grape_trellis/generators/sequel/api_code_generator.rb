module Grape
  module Trellis
    module Generators
      module Sequel
        class APICodeGenerator < CodeGenerator

          class << self
            def initial_require_code
              ['class API < Grape::API'] +
              ["  version 'v1', using: :header, vendor: 'Grape API' # using: :path"] +
              ['  format :json'] +
              ['  prefix :api'] +
              ['end'] +
              ["Dir[File.join(File.dirname(__FILE__), 'api/*.rb')].each {|f| require f }"]
            end
          end

          def filename
            "#{resource.table_name.underscore}.rb"
          end

          def code
            res = resource.table_name
            (
              ['class API < Grape::API'] +
              ["  resource :#{res} do"] +
              ['       '] +
              ['    helpers do'] +
              ["      def default_query"] +
              ["        JSON.generate(json: ["] +
              ['                              # specify JSON fields here'] +
              ["                            ])"] +
              ['      end'] +
              ['    end'] +
              ['       '] +
              ['    #########################################################################'] +
              ['    # REST endpoints'] +
              ["    desc 'index'"] +
              ["    get '/' do"] +
              ["      Jaql.resource(scope).index(default_query)"]
              ['    end'] +
              ['       '] +
              ["    desc 'show'"] +
              ["    params { requires :id, type: Integer, desc: 'The unique id of the #{res}' }"] +
              ["    get '/:id' do"] +
              ['    end'] +
              ['       '] +
              ['  end'] +
              ['end']
            ).join("\n")
          end

          def require_code
            []
            # "require 'api/#{filename}'"
          end


        end
      end
    end
  end
end
