require 'rubygems'
require 'simplecov'

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

Dir[File.join(CalcService.root, "spec/support/**/*.rb")].each {|f| require f}
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end