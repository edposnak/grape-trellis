# Require the base generator classes
require_relative 'generators/resource'
require_relative 'generators/generator'
require_relative 'generators/code_generator'

# Require all the derived generators
Dir[File.join(File.dirname(__FILE__), 'generators/*.rb')].each {|f| require f }

