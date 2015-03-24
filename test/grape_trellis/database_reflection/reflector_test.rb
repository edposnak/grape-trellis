require_relative '../../test_helper'

reflector = Grape::Trellis::DatabaseReflection::Reflector.new 'postgres://smcc@localhost:5432/smcc_development'
relations = reflector.reflect_on_database

