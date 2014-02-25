require 'rubygems'
require 'simplecov'
require 'stringio'
require 'singleton'
require 'json'
require 'cucumber/cli/main'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter
]
if ENV["RCOV"].to_s.downcase == 'true'
  SimpleCov.start do
    add_group "DRB", "lib"
    add_group "Root files" do |src_file|
      !src_file.filename.include?('/lib/')
    end
    add_filter { |src_file| src_file.filename.include?('spec/') }
    add_filter { |src_file| src_file.filename.include?('config/') }
  end
end

require 'rspec'

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each{ |f| require f }

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

def project_path
  File.expand_path(File.join(File.dirname(__FILE__), '..'))
end

def lib_path
  File.join(project_path, 'lib')
end