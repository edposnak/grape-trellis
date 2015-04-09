module Grape
  module Trellis
    module Generators
      module Sequel
        class FromDatabaseUrl < Generator
          # Generates code by reflecting on the database tables

          # Example
           #
           # Grape::Trellis::Generators::Sequel::FromDatabaseUrl.new.generate 'postgres://smcc@localhost:5432/smcc_development', 'lib', with_grape_entities: true, exclude_tables: /migration/

          # @param [String] database_url specifies database to connect to and reflect on
          # @param [String] target_dir where to put the generated code
          # @param [Hash] options
          # @option options types list of types to generate, default is [:api, :models]
          # @option options with_grape_entities add Grape::Entity presenters to generated models
          # @option options exclude_tables list or regex defining tables to exclude from reflection
          #
          def generate(database_url, target_dir, options={})
            generate_options   = options.slice(*VALID_GENERATE_OPTIONS)
            reflection_options = options.slice(*VALID_REFLECTION_OPTIONS)

            reflector = Dart::Reflection::SequelTable::Reflector.new(database_url)
            relations = reflector.get_relations_for_code_gen(reflection_options)
            types_to_generate = Array(options[:types] || [:models, :api])

            types_to_generate.each do |type|
              subdir = File.join(target_dir, type.to_s)
              FileUtils.mkdir_p(subdir)

              code_generator_class = code_generator_class_for(type)
              require_file_code    = code_generator_class.initial_require_code rescue []

              relations.each do |relation|
                code_generator = code_generator_class.new(relation, generate_options)
                File.open(File.join(subdir, "#{code_generator.filename}"), 'w') { |file| file.puts code_generator.code }
                require_file_code += code_generator.require_code
              end

              File.open("#{subdir}.rb", 'w') { |file| file.puts require_file_code.join("\n") }
            end
          end

          private

          VALID_GENERATE_OPTIONS   = [:with_grape_entities]
          VALID_REFLECTION_OPTIONS = [:exclude_tables]

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
