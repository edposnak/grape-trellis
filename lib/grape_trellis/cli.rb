require 'grape_trellis'

module Grape
  module Trellis
    class CLI < Thor::Group
      include Thor::Actions

      # Define arguments and options
      argument :name
      class_option :test_framework, :default => :test_unit

      module ClassMethods
        # Returns the path to the template files
        def source_root
          default_source_root
        end

        def default_source_root
          # return unless base_name && generator_name
          return unless default_generator_root
          path = File.join(default_generator_root, 'templates')
          path if File.exists?(path)
        end

        def default_generator_root
          # path = File.expand_path(File.join(base_name, generator_name), File.dirname(__FILE__))
          path = File.expand_path('../templates', File.dirname(__FILE__))
          puts "\n\n****************************** default_generator_root path = #{path} \n"
          path if File.exists?(path)
        end
      end
      extend ClassMethods

      no_commands do
        # not a Thor command
        def helper_method

        end
      end

      def create_lib_file
        template('templates/newgem.tt', "#{name}/lib/#{name}.rb")
      end

      def create_test_file
        test = options[:test_framework] == "rspec" ? :spec : :test
        create_file "#{name}/#{test}/#{name}_#{test}.rb"
      end

      def copy_licence
        if yes?("Use MIT license?")
          # Make a copy of the MITLICENSE file at the source root
          copy_file "MITLICENSE", "#{name}/MITLICENSE"
        else
          say "Shame on you…", :red
        end
      end
    end
  end
end
