$:.unshift File.expand_path('../lib', __FILE__)

require 'timecop'
require 'simplecov'
require 'rack/test'
SimpleCov.start

require 'buchestache'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.before(:all) do
    # Muting the output from the logger
    Buchestache::Outputs::IO.class_variable_set(:@@default_io, File.open(File::NULL, File::WRONLY))
  end
end

def unconfigure_foostash!
  %w(@source @base_tags @output @store_name @configured).each do |var|
    Buchestache.instance_variable_set(var, nil)
  end
end
