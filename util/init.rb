require 'stringio'
require 'singleton'
require 'json'
require 'cucumber/cli/main'
require 'debugger'

require_relative './sexy_settings_config'
require_relative './page_identifier'
require_relative './data_cacher'
require_relative './cucumber_parser'

def log(msg)
  puts "[INFO] #{msg}"
  t0 = Time.now
  yield
  duration = Time.now - t0
  puts "Done! [Duration: #{duration} sec.]"
end

log("Parsing page classes ...") do
  API.page_identifier
end

log("Data cacher initialization ...") do
  API.data_cacher
end

log("Parsing Cucumber features and caching them ...") do
  API.cucumber_parser.run
end