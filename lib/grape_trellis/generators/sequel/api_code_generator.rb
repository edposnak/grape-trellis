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
              ['    '] +
              ["      # Returns the client's JSON query or a default if none given"] +
              ['      def json_query'] +
              ['        params[:json_query] || default_query'] +
              ['      end'] +
              ['    '] +
              ['      private'] +
              ['    '] +
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
              ["      scope = #{model_class_name}.all "] +
              ["      Jaql.resource(scope).index(json_query)"] +
              ['    end'] +
              ['       '] +
              ["    desc 'show'"] +
              ["    params { requires :id, type: Integer, desc: 'The unique id of the #{res}' }"] +
              ["    get '/:id' do"] +
              ["      scope = #{model_class_name}.where(id: params[:id]) "] +
              ["      Jaql.resource(scope).show(json_query)"] +
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
