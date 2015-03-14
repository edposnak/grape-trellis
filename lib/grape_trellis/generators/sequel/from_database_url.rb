module Grape
  module Trellis
    module Generators
      module Sequel
        class FromDatabaseUrl < Generator
          # Generates code by reflecting on the database tables

          # Example
          # FromDatabaseUrl.new.generate 'postgres://smcc@localhost:5432/smcc_development', './lib', with_grape_entities: true

          # @param [String] database_url specifies database to connect to and reflect on
          # @param [String] target_dir where to put the generated code
          # @param [Hash] options
          # @option options with_grape_entities add Grape::Entity presenters to generated models
          # @option options db_reflection_options options to pass to reflect_on_database (exclude_tables_regex, naming_conventions, etc.)
          #
          def generate(database_url, target_dir, options={})
            database_url or fail InvalidArgumentError.new("database_url must be provided")
            target_dir or fail InvalidArgumentError.new("target_dir must be provided")

            generate_options = options.select {|k, _| VALID_GENERATE_OPTIONS.include? k}
            options[:db_reflection_options] ||= {}

            # TODO move this outside generate
            options[:db_reflection_options][:exclude_tables_regex] ||= /migration/ # exclude rails schema_migrations etc.

            reflector = DatabaseReflection::Reflector.new(database_url)
            relations = reflector.reflect_on_database(options[:db_reflection_options])

            [:models, :api].each do |type|
              target_dir = File.join(target_dir, type.to_s)
              FileUtils.mkdir_p(target_dir)

              code_generator_class = code_generator_class_for(type)
              require_file_code    = []

              relations.each do |relation|
                code_generator = code_generator_class.new(relation, generate_options)
                File.open(File.join(target_dir, "#{code_generator.filename}"), 'w') { |file| file.puts code_generator.code }
                require_file_code << code_generator.require_code
              end

              File.open("#{target_dir}.rb", 'w') { |file| file.puts require_file_code.join("\n") }
            end
          end

          private

          VALID_GENERATE_OPTIONS = [:with_grape_entities]

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
