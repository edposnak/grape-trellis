# Grape::Trellis::Generators::Sequel::FromDatabaseUrl.new.generate database_url: http://localhost:5432/smcc_development lib_dir: lib_dir, with_grape_entities: true
module Grape
  module Trellis
    module Generators
      module Sequel
        class FromDatabaseUrl < Generator

          # @param [Hash] options
          # @option options lib_dir where to put the generated code
          # @option options with_grape_entities add Grape::Entity presenters to generated models

          # @option options database_url the database to connect to and reflect on
          # @option options foreign_key_regex a regex to use to identify foreign key columns
          # @option options sequel_connect_options options to pass to Sequel.connect (max_connections, logger, etc.)
          #
          def generate(options={})
            reflect_options, generate_options = split_options(options)

            resources = reflect_on_database reflect_options

            generate_files [:models, :api], resources, generate_options
          end

          private

          def split_options(options)
            reflect_options  = options.select { |key, _| [:database_url, :foreign_key_regex, :sequel_connect_options].include?(key) }
            generate_options = options.select { |key, _| [:lib_dir, :with_grape_entities].include?(key) }

            # fail early if required options are not provided
            reflect_options[:database_url] or fail 'a database_url must be provided'
            generate_options[:lib_dir] or fail 'a lib_dir must be provided'

            [Hash[reflect_options], Hash[generate_options]]
          end

          # @param [Hash] options
          # @option options database_url specifies database to connect to and reflect on
          # @option options foreign_key_regex specifies a regex to use to identify foreign key columns
          # @option options sequel_connect_options options to pass to Sequel.connect (max_connections, logger, etc.)
          #
          def reflect_on_database(options)
            database_url           = options[:database_url]
            sequel_connect_options = options[:sequel_connect_options] || {}
            db                     = ::Sequel.connect(database_url, sequel_connect_options)
            model_tables           = db.tables.select { |t| t.to_s !~ /migration/ } # exclude rails schema_migrations etc.
            model_class_map        = Hash[model_tables.map { |table| [table, Resource.new(table, db[table].columns)] }]

            foreign_key_regex = options[:foreign_key_regex] || /_id$/

            # Build up the resources by inspecting tables
            model_class_map.keys.each do |table|
              model_class  = model_class_map[table]
              foreign_keys = model_class.column_names.select { |c| c =~ foreign_key_regex }
              foreign_keys.each do |foreign_key|
                # TODO remove assumption that foreign_key_regex ends with $
                one_model_table = foreign_key[0...foreign_key.index(foreign_key_regex)].pluralize.to_sym
                one_model_class = model_class_map[one_model_table]
                model_class.belongs_to(one_model_class) if one_model_class
              end
            end

            model_class_map.values
          end

          def generate_files types, resources, options={}
            types.each do |type|
              target_dir = File.join(options[:lib_dir], type.to_s)
              FileUtils.mkdir_p(target_dir)

              code_generator_class = code_generator_class_for(type)
              require_file_code    = []

              resources.each do |resource|
                code_generator = code_generator_class.new(resource, options)
                File.open(File.join(target_dir, "#{code_generator.filename}"), 'w') { |file| file.puts code_generator.code }
                require_file_code << code_generator.require_code
              end

              File.open("#{target_dir}.rb", 'w') do |file|
                file.puts require_file_code.join("\n")
              end
            end
          end

          def code_generator_class_for(type)
            case type
            when :models
              ModelCodeGenerator
            when :api
              APICodeGenerator
            else
              raise "no code generator registered for '#{type}'"
            end
          end

        end
      end
    end
  end
end
