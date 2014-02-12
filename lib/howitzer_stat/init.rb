require 'stringio'
require 'singleton'
require 'json'
require 'cucumber/cli/main'
require 'debugger'

require_relative '../../config/sexy_settings_config'
require_relative './page_identifier'
require_relative './data_cacher'
require_relative './cucumber_parser'

module HowitzerStat
  def self.log(msg)
    puts "[INFO] #{msg}"
    t0 = Time.now
    yield
    duration = Time.now - t0
    puts "Done! [Duration: #{duration} sec.]"
  end

  log("Parsing page classes ...") { page_identifier }
  log("Data cacher initialization ...") { data_cacher }
  log("Parsing Cucumber features and caching them ...") { cucumber_parser.run }
end