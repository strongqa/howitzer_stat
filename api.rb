require 'rubygems'
require 'bundler/setup'
require 'singleton'

Bundler.require

# --  API  --


# --  Helpers  --

class DataCacher
  include Singleton
  def initialize
    @data = {}
    @data.default = {}
  end

  def set(page_class, stat)
    key = normalize_page_class(page_class)
    @data[key] = stat if key
  end

  def get(page_class)
    key = normalize_page_class(page_class)
    @data[key]
  end

  private

  def normalize_page_class(page_class)
    page_class = page_class.to_s.downcase
    if page_class.empty? || page_class.nil?
      nil
    else
      page_class
    end
  end
end

def dc
  DataCacher.instance
end

#dc.set('LoginPage', {bla: 'blablabla'})
#puts dc.get('LoginPage')
#puts dc.get(nil)
#puts dc.get('UnknownPage')

SexySettings.configure do |config|
  config.path_to_project = __dir__
  config.path_to_default_settings = File.join(__dir__, 'config', "default.yml")
  config.path_to_custom_settings = File.join(__dir__, 'config', "custom.yml")
end

def api_settings
  SexySettings::Base.instance
end

#puts api_settings.foo

exit