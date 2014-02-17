require 'stringio'
require 'singleton'
require 'json'
require 'cucumber/cli/main'
require 'debugger'

require_relative '../../config/sexy_settings_config'
module HowitzerStat
  def self.log(msg)
    puts "[#{Time.now.utc}][INFO] #{msg}"
    t0 = Time.now
    yield
    duration = Time.now - t0
    puts "Done! [Duration: #{duration} sec.]"
  end
end
require_relative './page_identifier'
require_relative './data_cacher'
require_relative './cucumber_parser'
require_relative './page_refreshing_job'
require_relative './cache_refreshing_job'